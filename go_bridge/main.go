//go:build cgo
// +build cgo

package main

/*
#include <stdlib.h>

// Event type constants passed to the Dart callback
#define CROC_EVENT_PROGRESS 1
#define CROC_EVENT_COMPLETE 2
#define CROC_EVENT_ERROR   3
#define CROC_EVENT_CODE     4
*/
import "C"

import (
	"bytes"
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"os"
	"path/filepath"
	"regexp"
	"strconv"
	"strings"
	"sync"
	"sync/atomic"
	"time"
	"unsafe"

	"github.com/schollz/croc/v11/src/comm"
	"github.com/schollz/croc/v11/src/croc"
	"github.com/schollz/croc/v11/src/models"
	"github.com/schollz/croc/v11/src/utils"
	"github.com/schollz/croc/v11/src/version"
)

// ── Global state ────────────────────────────────────────────
var (
	// mu guards active only. Everything else a transfer needs lives on its
	// session, so a later transfer can never write into an earlier one's
	// event channel.
	mu     sync.Mutex
	active *session

	// transferSeq hands out process-unique transfer ids. os.Getpid() cannot:
	// it returns the same value for the whole process lifetime.
	transferSeq atomic.Uint64
)

// errTransferInProgress is returned when a transfer is started while another
// one is still running.
var errTransferInProgress = errors.New("a transfer is already in progress")

// eventQueueDepth is how many events may pile up before the consumer polls.
const eventQueueDepth = 100

// session owns the state of one transfer: the channel its events travel on and
// the context that cancels it.
type session struct {
	id     string
	ctx    context.Context
	cancel context.CancelFunc

	// emitMu guards closed against closeEvents. Holding it across the send is
	// safe because the send never blocks.
	emitMu sync.Mutex
	events chan progressEvent
	closed bool

	// finished is set once the transfer goroutine has returned, which is what
	// lets the next transfer claim the slot.
	finished atomic.Bool

	// drained is set once the consumer has seen the closed channel, so the
	// terminal event is reported exactly once.
	drained atomic.Bool
}

// newSession claims the single transfer slot. A finished session is replaced;
// one that is still running blocks the new transfer.
func newSession() (*session, error) {
	mu.Lock()
	defer mu.Unlock()
	if active != nil && !active.finished.Load() {
		return nil, errTransferInProgress
	}
	ctx, cancel := context.WithCancel(context.Background())
	s := &session{
		id:     strconv.FormatUint(transferSeq.Add(1), 10),
		ctx:    ctx,
		cancel: cancel,
		events: make(chan progressEvent, eventQueueDepth),
	}
	active = s
	return s, nil
}

// run starts fn on a goroutine and closes the event channel when it returns.
// A panic in fn is turned into a type-3 error event instead of escaping the
// c-shared boundary, where it would take the host process down with it.
func (s *session) run(fn func(s *session)) {
	go func() {
		defer s.cancel()
		defer s.markFinished()
		defer s.closeEvents()
		defer func() {
			if r := recover(); r != nil {
				s.emit(progressEvent{Type: 3, Error: fmt.Sprintf("bridge panic: %v", r)})
			}
		}()
		fn(s)
	}()
}

// emit queues an event. It drops the event when the consumer is behind rather
// than blocking, and it never sends on a closed channel.
func (s *session) emit(ev progressEvent) {
	ev.TransferID = s.id
	s.emitMu.Lock()
	defer s.emitMu.Unlock()
	if s.closed {
		return
	}
	select {
	case s.events <- ev:
	default:
	}
}

func (s *session) closeEvents() {
	s.emitMu.Lock()
	defer s.emitMu.Unlock()
	if !s.closed {
		s.closed = true
		close(s.events)
	}
}

func (s *session) markFinished() { s.finished.Store(true) }

// Event type for status messages (e.g. croc v11 reconnect notices).
// Dart clients that don't recognise type 5 simply ignore it.
const eventTypeStatus = 5

// Event type for live transfer progress (bytes / file index / speed).
// Kept in sync with CROC_EVENT_PROGRESS in the cgo preamble.
const eventTypeProgress = 1

// progressSampleInterval is how often the sampler reads croc's counters.
// croc's own terminal progress bar redraws at a similar cadence, and the Dart
// side polls at 200ms, so anything faster would just queue up samples.
const progressSampleInterval = 200 * time.Millisecond

// maxTextTransferBytes mirrors croc's internal limit
// (src/croc/croc.go: `maxTextTransferBytes = 1 << 20`). Since croc v11.5 the
// receiver validates text offers via validateSendingTextOffer() and rejects
// anything outside 1 byte..1 MiB, so the sender must respect the same bound.
const maxTextTransferBytes = 1 << 20

type progressEvent struct {
	Type             int     `json:"type"`
	TransferID       string  `json:"transfer_id"`
	TotalFiles       int     `json:"total_files"`
	TotalSize        int64   `json:"total_size"`
	TransferredSize  int64   `json:"transferred_size"`
	CurrentFile      string  `json:"current_file"`
	CurrentFileIndex int     `json:"current_file_index"`
	Speed            float64 `json:"speed"`
	CodePhrase       string  `json:"code_phrase"`
	Error            string  `json:"error"`
	IsText           bool    `json:"is_text"`
	TextContent      string  `json:"text_content"`
}

// ── Exported C API ──────────────────────────────────────────

//export CrocGetVersion
func CrocGetVersion() *C.char {
	return C.CString("croc v" + version.Value)
}

//export CrocSendFiles
func CrocSendFiles(pathsJSON *C.char, optionsJSON *C.char) *C.char {
	var paths []string
	if err := json.Unmarshal([]byte(C.GoString(pathsJSON)), &paths); err != nil {
		return marshalError(fmt.Sprintf("invalid paths: %s", err))
	}

	var opts sendOptions
	if err := json.Unmarshal([]byte(C.GoString(optionsJSON)), &opts); err != nil {
		return marshalError(fmt.Sprintf("invalid options: %s", err))
	}

	s, err := newSession()
	if err != nil {
		return marshalError(err.Error())
	}

	code := opts.CodePhrase
	if code == "" {
		code = utils.GetRandomName()
	}

	s.run(func(s *session) {
		doSend(s, paths, code, opts)
	})

	// Return transfer_id + code immediately
	return marshalResult(s.id, code)
}

//export CrocReceiveFiles
func CrocReceiveFiles(codePhrase *C.char, optionsJSON *C.char) *C.char {
	var opts receiveOptions
	if err := json.Unmarshal([]byte(C.GoString(optionsJSON)), &opts); err != nil {
		return marshalError(fmt.Sprintf("invalid options: %s", err))
	}

	s, err := newSession()
	if err != nil {
		return marshalError(err.Error())
	}

	code := C.GoString(codePhrase) // copy before goroutine (Dart frees ptr after return)

	s.run(func(s *session) {
		doReceive(s, code, opts)
	})

	return marshalResult(s.id, "")
}

//export CrocPollProgress
func CrocPollProgress() *C.char {
	mu.Lock()
	s := active
	mu.Unlock()
	if s == nil {
		return C.CString("null")
	}
	select {
	case ev, ok := <-s.events:
		if !ok {
			// Report the closed channel once: reading it again would keep
			// succeeding and flood the consumer with terminal events.
			if !s.drained.Swap(true) {
				return marshalEvent(&progressEvent{Type: 2, TransferID: "closed"})
			}
			return C.CString("null")
		}
		return marshalEvent(&ev)
	default:
		return C.CString("null")
	}
}

//export CrocCancelTransfer
func CrocCancelTransfer(transferID *C.char) C.int {
	id := C.GoString(transferID)
	mu.Lock()
	s := active
	mu.Unlock()
	if s == nil || s.finished.Load() {
		return 0
	}
	// An empty id means "whatever is running". A non-empty one must match, so
	// a stale id left over from a finished transfer cannot cancel this one.
	if id != "" && id != s.id {
		return 0
	}
	s.cancel()
	return 1
}

//export CrocFreeString
func CrocFreeString(str *C.char) {
	C.free(unsafe.Pointer(str))
}

// ── Internal helpers ────────────────────────────────────────

func marshalResult(transferID, code string) *C.char {
	r := map[string]string{"transfer_id": transferID}
	if code != "" {
		r["code_phrase"] = code
	}
	b, _ := json.Marshal(r)
	return C.CString(string(b))
}

func marshalError(msg string) *C.char {
	b, _ := json.Marshal(map[string]string{"error": msg})
	return C.CString(string(b))
}

func marshalEvent(ev *progressEvent) *C.char {
	if ev == nil {
		return C.CString("{}")
	}
	b, _ := json.Marshal(ev)
	return C.CString(string(b))
}

// captureStderr redirects os.Stderr into a pipe and scans croc's output for
// reconnect notices (croc v11 prints "…detected a transfer interruption.
// Retrying securely…" to stderr). When matched, a type-5 status event is
// queued so the Flutter UI can show "reconnecting" instead of appearing
// stuck. All other stderr content is discarded.
//
// croc.New() with Quiet=true replaces os.Stderr with os.DevNull and never
// restores it, so this must be called AFTER croc.New() to take effect.
// The returned restore function must be called when the transfer ends.
func captureStderr(s *session) (restore func()) {
	oldStderr := os.Stderr
	r, w, err := os.Pipe()
	if err != nil {
		return func() {}
	}
	os.Stderr = w

	done := make(chan struct{})
	go func() {
		defer close(done)
		defer r.Close()
		buf := make([]byte, 4096)
		carry := ""
		for {
			n, err := r.Read(buf)
			if n > 0 {
				carry = scanNotices(carry+string(buf[:n]), s)
			}
			if err != nil {
				return
			}
		}
	}()

	return func() {
		w.Close()
		os.Stderr = oldStderr
		<-done
	}
}

// scanNotices emits a status event for every reconnect notice in chunk and
// returns the trailing bytes that might still be part of an unfinished line.
//
// It deliberately does not use bufio.Scanner. croc's progress bar redraws with
// "\r" and only writes "\n" once a file completes, so a single large file
// blows past the scanner's 64 KiB token limit; the scanner then stops reading
// for good, the pipe fills up, and croc blocks forever on its next write to
// stderr — a transfer that hangs without producing any error.
func scanNotices(chunk string, s *session) string {
	for {
		i := strings.IndexByte(chunk, '\n')
		if i < 0 {
			break
		}
		line := chunk[:i]
		if strings.Contains(line, "transfer interruption") ||
			strings.Contains(line, "Retrying securely") {
			s.emit(progressEvent{Type: eventTypeStatus, Error: "reconnecting"})
		}
		chunk = chunk[i+1:]
	}
	// Unterminated tail: keep only enough to still recognise a notice that
	// straddles a read boundary, so it cannot grow without bound.
	if len(chunk) > 4096 {
		return chunk[len(chunk)-512:]
	}
	return chunk
}

// ── Live progress sampling ──────────────────────────────────
//
// croc.ProgressSnapshot() returns a consistent copy of the transfer counters
// (src/croc/progress.go in the croc fork). Reading the exported fields
// directly instead would race with croc's own transfer goroutines — and
// FilesHasFinished is a map, whose concurrent read is a fatal error that
// cannot be recovered.
type progressSampler struct {
	session *session
	client  *croc.Client

	stopOnce sync.Once
	done     chan struct{} // closed to ask the sampler to stop
	stopped  chan struct{} // closed once the goroutine has exited

	lastSent int64
	lastAt   time.Time
}

// startProgressSampler begins emitting type-1 progress events. The returned
// sampler MUST be stopped before the session's event channel is closed.
func startProgressSampler(s *session, c *croc.Client) *progressSampler {
	sm := &progressSampler{
		session: s,
		client:  c,
		done:    make(chan struct{}),
		stopped: make(chan struct{}),
		lastAt:  time.Now(),
	}
	go sm.run()
	return sm
}

// stop halts the sampler and waits for the goroutine to exit, so no sample can
// race with the closing of the session's event channel.
func (sm *progressSampler) stop() {
	if sm == nil {
		return
	}
	sm.stopOnce.Do(func() { close(sm.done) })
	<-sm.stopped
}

func (sm *progressSampler) run() {
	defer close(sm.stopped)
	ticker := time.NewTicker(progressSampleInterval)
	defer ticker.Stop()
	for {
		select {
		case <-sm.done:
			return
		case <-ticker.C:
			sm.session.emit(sm.sample())
		}
	}
}

// sample builds one progress event from croc's own snapshot, which is already
// locked and therefore needs no recover() guard.
func (sm *progressSampler) sample() progressEvent {
	snap := sm.client.ProgressSnapshot()

	now := time.Now()
	elapsed := now.Sub(sm.lastAt).Seconds()
	var speed float64
	if elapsed > 0 && snap.TransferredSize >= sm.lastSent {
		speed = float64(snap.TransferredSize-sm.lastSent) / elapsed
	}
	sm.lastSent, sm.lastAt = snap.TransferredSize, now

	index := snap.CurrentFileIndex
	if snap.TotalFiles == 0 {
		// The manifest has not arrived yet, so there is no current file.
		index = 0
	}

	return progressEvent{
		Type:             eventTypeProgress,
		TotalFiles:       snap.TotalFiles,
		TotalSize:        snap.TotalSize,
		TransferredSize:  snap.TransferredSize,
		CurrentFile:      snap.CurrentFile,
		CurrentFileIndex: index,
		Speed:            speed,
	}
}

func doSend(s *session, paths []string, code string, opts sendOptions) {
	// Handle text mode: write text content to a temp file.
	// croc recognises the "croc-stdin-" prefix as stdin/text content.
	sendingText := opts.SendingText && opts.TextContent != ""
	if sendingText {
		// croc v11.5+ validates text offers on the receiver. Reject oversized
		// payloads here so the user gets a clear local error instead of a
		// failed transfer ("text transfer size must be between 1 byte and 1 MiB").
		if n := len(opts.TextContent); n > maxTextTransferBytes {
			s.emit(progressEvent{Type: 3, Error: fmt.Sprintf(
				"text too large: %d bytes (croc limit is %d bytes / 1 MiB)", n, maxTextTransferBytes)})
			return
		}
		tmpDir := opts.TempDir
		tmpFile, err := os.CreateTemp(tmpDir, "croc-stdin-*.txt")
		if err != nil {
			s.emit(progressEvent{Type: 3, Error: fmt.Sprintf("temp file: %s", err)})
			return
		}
		defer os.Remove(tmpFile.Name())
		if _, err := tmpFile.WriteString(opts.TextContent); err != nil {
			s.emit(progressEvent{Type: 3, Error: fmt.Sprintf("write text: %s", err)})
			return
		}
		tmpFile.Close()
		paths = []string{tmpFile.Name()}
	}

	// Ensure we have at least one path
	if len(paths) == 0 {
		s.emit(progressEvent{Type: 3, Error: "no files to send"})
		return
	}

	// Use croc public relay defaults when no explicit address is configured.
	// The vendored croc has been patched so the public-relay goroutine
	// returns silently (instead of sending a spurious error) when both
	// addresses are empty — so local relay and public relay coexist properly.
	relayAddr := opts.RelayAddress
	if relayAddr == "" {
		relayAddr = models.DEFAULT_RELAY
	}
	if relayAddr == "" {
		relayAddr = fallbackRelay
	}
	relayAddr6 := opts.RelayAddress6
	if relayAddr6 == "" {
		relayAddr6 = models.DEFAULT_RELAY6
	}
	if relayAddr6 == "" {
		relayAddr6 = fallbackRelay6
	}
	relayPass := opts.RelayPassword
	if relayPass == "" {
		relayPass = models.DEFAULT_PASSPHRASE
	}
	curve := opts.Curve
	if curve == "" {
		curve = defaultCurve
	}
	hashAlgo := opts.HashAlgorithm
	if hashAlgo == "" {
		hashAlgo = defaultHashAlgo
	}

	relayPorts := parseRelayPorts(opts.RelayPorts)

	// croc's CLI copies the share code (and, in extended mode, the whole
	// receive command) into the OS clipboard while printing its instructions.
	// That silently destroys whatever the user had copied, and a GUI has no
	// business doing it. Default to leaving the clipboard alone; the caller can
	// still opt back in explicitly.
	disableClipboard := true
	if opts.DisableClipboard != nil {
		disableClipboard = *opts.DisableClipboard
	}

	// Validate here so an unknown value surfaces as a readable error instead of
	// a croc.New failure. Empty means "auto".
	transport, err := croc.ParseTransportMode(opts.Transport)
	if err != nil {
		s.emit(progressEvent{Type: 3, Error: err.Error()})
		return
	}

	throttle, err := normalizeThrottle(opts.ThrottleUpload)
	if err != nil {
		s.emit(progressEvent{Type: 3, Error: err.Error()})
		return
	}

	applyProxies(opts.Socks5Proxy, opts.HttpProxy)

	crocOpts := croc.Options{
		IsSender:         true,
		SharedSecret:     code,
		Debug:            false,
		RelayAddress:     relayAddr,
		RelayAddress6:    relayAddr6,
		RelayPorts:       relayPorts,
		RelayPassword:    relayPass,
		NoPrompt:         true,
		DisableLocal:     opts.DisableLocal,
		OnlyLocal:        opts.OnlyLocal,
		Curve:            curve,
		HashAlgorithm:    hashAlgo,
		NoCompress:       opts.NoCompress,
		Overwrite:        opts.Overwrite,
		ZipFolder:        opts.ZipFolder,
		GitIgnore:        opts.GitIgnore,
		SendingText:      sendingText,
		Quiet:            true,
		DisableClipboard: disableClipboard,
		Transport:        transport,
		ThrottleUpload:   throttle,
	}

	s.emit(progressEvent{Type: 4, CodePhrase: code})

	// NewCtx instead of New: it marks the client as GUI-driven, so a panic
	// while processing the peer's PAKE message is logged and turned into a
	// cancellation instead of being re-panicked out of the c-shared library,
	// and it ties the relay and the file hashing to a cancellable context.
	c, err := croc.NewCtx(s.ctx, crocOpts)
	if err != nil {
		s.emit(progressEvent{Type: 3, Error: err.Error()})
		return
	}

	// croc.New(Quiet) sent stderr to DevNull; restore + capture it so we can
	// surface croc v11 reconnect notices as status events.
	restoreStderr := captureStderr(s)
	defer restoreStderr()

	filesInfo, emptyFolders, totalFolders, err := croc.GetFilesInfo(
		paths, crocOpts.ZipFolder, crocOpts.GitIgnore, opts.Exclude,
	)
	if err != nil {
		s.emit(progressEvent{Type: 3, Error: err.Error()})
		return
	}

	var totalSize int64
	for _, f := range filesInfo {
		totalSize += f.Size
	}

	// Emit live progress while croc moves the data.
	sampler := startProgressSampler(s, c)
	defer sampler.stop()

	err = c.Send(filesInfo, emptyFolders, totalFolders)
	if err != nil {
		s.emit(progressEvent{Type: 3, Error: err.Error()})
		return
	}

	s.emit(progressEvent{
		Type:       2,
		TotalFiles: len(filesInfo),
		TotalSize:  totalSize,
	})
}

func doReceive(s *session, code string, opts receiveOptions) {
	relayAddr := opts.RelayAddress
	if relayAddr == "" {
		relayAddr = models.DEFAULT_RELAY
	}
	if relayAddr == "" {
		relayAddr = fallbackRelay
	}
	relayAddr6 := opts.RelayAddress6
	if relayAddr6 == "" {
		relayAddr6 = models.DEFAULT_RELAY6
	}
	if relayAddr6 == "" {
		relayAddr6 = fallbackRelay6
	}
	relayPass := opts.RelayPassword
	if relayPass == "" {
		relayPass = models.DEFAULT_PASSPHRASE
	}
	relayPorts := parseRelayPorts(opts.RelayPorts)

	curve := opts.Curve
	if curve == "" {
		curve = defaultCurve
	}

	hashAlgo := opts.HashAlgorithm
	if hashAlgo == "" {
		hashAlgo = defaultHashAlgo
	}

	// Default to croc's --rename behaviour. Without it croc asks
	// "(y/N) Overwrite?" on stdin when the destination already exists
	// (askReceiveOverwrite); a GUI has nothing on stdin, the read returns
	// empty, the answer is read as "no", and croc `continue`s — the file is
	// silently dropped. Renaming is the only lossless choice that needs no user
	// interaction.
	rename := true
	if opts.Rename != nil {
		rename = *opts.Rename
	}

	applyProxies(opts.Socks5Proxy, opts.HttpProxy)

	crocOpts := croc.Options{
		IsSender:      false,
		SharedSecret:  code,
		Debug:         false,
		RelayAddress:  relayAddr,
		RelayAddress6: relayAddr6,
		RelayPorts:    relayPorts,
		RelayPassword: relayPass,
		NoPrompt:      true,
		OnlyLocal:     opts.OnlyLocal,
		Curve:         curve,
		HashAlgorithm: hashAlgo,
		Overwrite:     opts.Overwrite,
		Rename:        rename,
		Quiet:         true,
	}

	c, err := croc.NewCtx(s.ctx, crocOpts)
	if err != nil {
		s.emit(progressEvent{Type: 3, Error: err.Error()})
		return
	}

	// croc.New(Quiet) sent stderr to DevNull; restore + capture it so we can
	// surface croc v11 reconnect notices as status events.
	restoreStderr := captureStderr(s)
	defer restoreStderr()

	if opts.OutputPath != "" {
		os.Chdir(opts.OutputPath)
	}

	// Signal that transfer has started (type 4 — mirrors doSend)
	s.emit(progressEvent{Type: 4})

	// Emit live progress while croc moves the data.
	sampler := startProgressSampler(s, c)
	defer sampler.stop()

	// Capture stdout during receive — croc echoes the text payload to stdout
	// when SendingText is true, then `transfer()` deletes the received file
	// (`if c.Options.Stdout && !c.Options.IsSender { root.Remove(pathToFile) }`).
	// By capturing stdout we get the text without modifying croc source.
	var capturedStdout string
	oldStdout := os.Stdout
	r, w, pipeErr := os.Pipe()
	if pipeErr == nil {
		os.Stdout = w
		var stdoutBuf bytes.Buffer
		stdoutDone := make(chan struct{})
		go func() {
			io.Copy(&stdoutBuf, r)
			r.Close()
			close(stdoutDone)
		}()

		err = c.Receive()

		w.Close()
		os.Stdout = oldStdout
		<-stdoutDone
		capturedStdout = stdoutBuf.String()
	} else {
		err = c.Receive()
	}

	if err != nil {
		s.emit(progressEvent{Type: 3, Error: err.Error()})
		return
	}

	// Collect received file info
	var totalSize int64
	var fileNames []string
	var isText bool
	var textContent string

	// Detect text receive: `c.Options.SendingText` is reliably set by the
	// receiver from the sender's info (processSenderInfo:
	// `c.Options.SendingText = senderInfo.SendingText`, right after the
	// validateSendingTextOffer() gate), which also flips `c.Options.Stdout` on
	// so the payload is echoed to stdout.
	if c.Options.SendingText {
		isText = true
		textContent = capturedStdout
		if textContent == "" && len(c.FilesToTransfer) == 1 {
			f := c.FilesToTransfer[0]
			filePath := filepath.Join(f.FolderRemote, f.Name)
			if data, err := os.ReadFile(filePath); err == nil {
				textContent = string(data)
			}
		}
	}
	if !isText {
		for _, f := range c.FilesToTransfer {
			if f.Name != "" {
				fileNames = append(fileNames, f.Name)
				totalSize += f.Size
			}
		}
	}

	s.emit(progressEvent{
		Type:        2,
		TotalFiles:  len(fileNames),
		TotalSize:   totalSize,
		CurrentFile: strings.Join(fileNames, "\n"),
		IsText:      isText,
		TextContent: textContent,
	})
}

// ── Option types (mirror Dart models) ────────────────────────

type sendOptions struct {
	CodePhrase    string   `json:"code_phrase"`
	Curve         string   `json:"curve"`
	HashAlgorithm string   `json:"hash_algorithm"`
	NoCompress    bool     `json:"no_compress"`
	Overwrite     bool     `json:"overwrite"`
	ZipFolder     bool     `json:"zip_folder"`
	GitIgnore     bool     `json:"git_ignore"`
	OnlyLocal     bool     `json:"only_local"`
	DisableLocal  bool     `json:"disable_local"`
	RelayAddress  string   `json:"relay_address"`
	RelayAddress6 string   `json:"relay_address6"`
	RelayPassword string   `json:"relay_password"`
	RelayPorts    string   `json:"relay_ports"`
	Exclude       []string `json:"exclude"`
	SendingText   bool     `json:"sending_text"`
	TextContent   string   `json:"text_content"`
	TempDir       string   `json:"temp_dir"`

	// DisableClipboard mirrors croc's --disable-clipboard. It is a pointer so
	// that "field absent" can be told apart from an explicit false: the bridge
	// defaults to NOT touching the system clipboard (see doSend).
	DisableClipboard *bool `json:"disable_clipboard"`

	// Transport selects the sender's file-data channel: "auto" (default),
	// "derp" (prefer the Tailcat/WireGuard direct path) or "relay".
	// croc rejects anything else, and rejects non-auto for receivers.
	Transport string `json:"transport"`

	// ThrottleUpload caps the upload rate, croc syntax: digits with an optional
	// k/m/g suffix ("500k", "5m", "1048576").
	ThrottleUpload string `json:"throttle_upload"`

	// Socks5Proxy / HttpProxy are applied to croc's package-level proxy globals
	// (see applyProxies).
	Socks5Proxy string `json:"socks5_proxy"`
	HttpProxy   string `json:"http_proxy"`
}

type receiveOptions struct {
	Curve         string `json:"curve"`
	HashAlgorithm string `json:"hash_algorithm"`
	Overwrite     bool   `json:"overwrite"`
	OnlyLocal     bool   `json:"only_local"`
	OutputPath    string `json:"output_path"`
	RelayAddress  string `json:"relay_address"`
	RelayAddress6 string `json:"relay_address6"`
	RelayPassword string `json:"relay_password"`
	RelayPorts    string `json:"relay_ports"`

	// Rename mirrors croc's --rename: on a name collision the incoming file is
	// saved under an unused name instead of prompting. Pointer for the same
	// reason as sendOptions.DisableClipboard — nil means "default", and the
	// default here is true, because a GUI has no stdin to answer croc's
	// (y/N) prompt with, which used to make croc silently skip the file.
	Rename *bool `json:"rename"`

	// Proxy configuration; see applyProxies.
	Socks5Proxy string `json:"socks5_proxy"`
	HttpProxy   string `json:"http_proxy"`
}

// parseRelayPorts parses comma-separated port string into []string.
// Falls back to default port range if empty or invalid.
func parseRelayPorts(raw string) []string {
	if raw == "" {
		return defaultRelayPorts()
	}
	parts := strings.Split(raw, ",")
	var ports []string
	for _, p := range parts {
		p = strings.TrimSpace(p)
		if p != "" {
			ports = append(ports, p)
		}
	}
	if len(ports) == 0 {
		return defaultRelayPorts()
	}
	return ports
}

// defaultRelayPorts returns the default relay port range matching croc CLI defaults.
func defaultRelayPorts() []string {
	const startPort = 9009
	const numPorts = 5 // transfers (4) + 1
	ports := make([]string, numPorts)
	for i := 0; i < numPorts; i++ {
		ports[i] = fmt.Sprintf("%d", startPort+i)
	}
	return ports
}

const defaultCurve = "p256"
const defaultHashAlgo = "xxhash"

// ── Upload throttle ─────────────────────────────────────────

// throttleRe matches croc's accepted --throttleUpload syntax: a positive
// integer with an optional single unit suffix (k/m/g, case-insensitive).
var throttleRe = regexp.MustCompile(`^[0-9]+[kKmMgG]?$`)

// normalizeThrottle validates an upload limit and returns the string to hand to
// croc ("" meaning "no limit").
//
// This has to be validated on our side: croc panics on a malformed value
// ("Could not parse given Upload Limit", croc.go:447/461) and a panic inside a
// c-shared library takes the whole host process — the Flutter app — down with
// it. A zero limit is equally fatal, because croc divides by it when building
// the rate limiter.
func normalizeThrottle(raw string) (string, error) {
	raw = strings.TrimSpace(raw)
	if raw == "" {
		return "", nil
	}
	if !throttleRe.MatchString(raw) {
		return "", fmt.Errorf("invalid upload limit %q: expected digits with an optional k/m/g suffix, e.g. 500k", raw)
	}
	amount, err := strconv.ParseInt(strings.TrimRight(raw, "kKmMgG"), 10, 64)
	if err != nil {
		return "", fmt.Errorf("invalid upload limit %q: %v", raw, err)
	}
	if amount <= 0 {
		// "0" and "0k" would both make croc divide by zero. Treat them as
		// "no limit" rather than rejecting an otherwise harmless input.
		return "", nil
	}
	return raw, nil
}

// ── Proxies ─────────────────────────────────────────────────

// applyProxies points croc at the configured SOCKS5 / HTTP proxies.
//
// croc reads these from package-level globals in src/comm, so they must be set
// before croc.New dials anything. Because they are process-wide, only one proxy
// configuration can be in flight at a time; the bridge drives a single transfer
// at a time, so that constraint is acceptable. Assigning unconditionally —
// including the empty string — also stops one transfer's proxy from leaking
// into the next.
func applyProxies(socks5, httpProxy string) {
	comm.Socks5Proxy = socks5
	comm.HttpProxy = httpProxy
}

// Fallback relay addresses used when models.DEFAULT_RELAY / DEFAULT_RELAY6
// resolve to empty (e.g. DNS failure during croc's init()).
// Port is intentionally omitted — croc defaults to DEFAULT_PORT (9009) and
// the relay banner overrides RelayPorts after connection.
const fallbackRelay = "croc.schollz.com"
const fallbackRelay6 = "croc6.schollz.com"

func main() {} // required for c-shared builds
