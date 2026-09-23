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
	"bufio"
	"bytes"
	"encoding/json"
	"fmt"
	"io"
	"os"
	"path/filepath"
	"strings"
	"sync"
	"time"
	"unsafe"

	"github.com/schollz/croc/v11/src/croc"
	"github.com/schollz/croc/v11/src/models"
	"github.com/schollz/croc/v11/src/utils"
	"github.com/schollz/croc/v11/src/version"
)

// ── Global state ────────────────────────────────────────────
var (
	mu           sync.Mutex
	activeClient *croc.Client
	progressChan chan progressEvent
)

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

	transferID := fmt.Sprintf("%d", os.Getpid())
	code := opts.CodePhrase
	if code == "" {
		code = utils.GetRandomName()
	}

	mu.Lock()
	progressChan = make(chan progressEvent, 100)
	ch := progressChan
	mu.Unlock()

	go func() {
		defer close(ch)
		doSend(paths, code, opts, transferID)
	}()

	// Return transfer_id + code immediately
	return marshalResult(transferID, code)
}

//export CrocReceiveFiles
func CrocReceiveFiles(codePhrase *C.char, optionsJSON *C.char) *C.char {
	var opts receiveOptions
	if err := json.Unmarshal([]byte(C.GoString(optionsJSON)), &opts); err != nil {
		return marshalError(fmt.Sprintf("invalid options: %s", err))
	}

	transferID := fmt.Sprintf("%d", os.Getpid())
	code := C.GoString(codePhrase) // copy before goroutine (Dart frees ptr after return)

	mu.Lock()
	progressChan = make(chan progressEvent, 100)
	ch := progressChan
	mu.Unlock()

	go func() {
		defer close(ch)
		doReceive(code, opts, transferID)
	}()

	return marshalResult(transferID, "")
}

//export CrocPollProgress
func CrocPollProgress() *C.char {
	mu.Lock()
	ch := progressChan
	mu.Unlock()
	if ch == nil {
		return marshalEvent(nil)
	}
	select {
	case ev, ok := <-ch:
		if !ok {
			// Channel closed — clear it.
			mu.Lock()
			if progressChan == ch {
				progressChan = nil
			}
			mu.Unlock()
			closedEvent := progressEvent{Type: 2, TransferID: "closed"}
			return marshalEvent(&closedEvent)
		}
		return marshalEvent(&ev)
	default:
		return C.CString("null")
	}
}

//export CrocCancelTransfer
func CrocCancelTransfer(transferID *C.char) C.int {
	mu.Lock()
	defer mu.Unlock()
	if activeClient != nil {
		activeClient.Cancel()
		return 1
	}
	return 0
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
func captureStderr(transferID string) (restore func()) {
	oldStderr := os.Stderr
	r, w, err := os.Pipe()
	if err != nil {
		return func() {}
	}
	os.Stderr = w

	done := make(chan struct{})
	go func() {
		defer close(done)
		scanner := bufio.NewScanner(r)
		for scanner.Scan() {
			line := scanner.Text()
			if strings.Contains(line, "transfer interruption") ||
				strings.Contains(line, "Retrying securely") {
				progressChan <- progressEvent{
					Type:       eventTypeStatus,
					TransferID: transferID,
					Error:      "reconnecting",
				}
			}
		}
	}()

	return func() {
		w.Close()
		os.Stderr = oldStderr
		<-done
	}
}

// ── Live progress sampling ──────────────────────────────────
//
// croc keeps its transfer counters on the *exported* fields of croc.Client
// (src/croc/croc.go), so the bridge can read them without patching croc:
//
//	TotalSent                int64  — bytes moved for the CURRENT file
//	                                 (reset per file: croc.go:3199 / 3519)
//	FilesToTransferCurrentNum int   — index of the file in flight
//	TotalNumberOfContents    int    — total number of entries
//	FilesToTransfer          []FileInfo
//
// Overall progress therefore is:
//
//	sum(sizes[0 .. currentNum-1]) + TotalSent
//
// Caveat: croc mutates these fields from its own goroutines without a lock
// that we can share, so a sample can observe a torn value. Every read is
// wrapped in a recover() so a torn slice header degrades into a skipped
// sample instead of taking the process down. Note that FilesHasFinished is a
// map and is deliberately never read — a concurrent map read is a fatal
// runtime error in Go, not a recoverable panic.
type progressSampler struct {
	transferID string
	totalSize  int64
	totalFiles int
	// sizes is the sender's own file-size list. When nil (receiver side) the
	// sizes are read from the client's manifest instead.
	sizes []int64

	stopOnce sync.Once
	done     chan struct{} // closed to ask the sampler to stop
	stopped  chan struct{} // closed once the goroutine has exited

	lastSent int64
	lastAt   time.Time
}

// startProgressSampler begins emitting type-1 progress events. totalSize and
// totalFiles may be 0, in which case they are derived from the client.
// The returned sampler MUST be stopped before progressChan is closed.
func startProgressSampler(transferID string, totalSize int64, totalFiles int, sizes []int64) *progressSampler {
	s := &progressSampler{
		transferID: transferID,
		totalSize:  totalSize,
		totalFiles: totalFiles,
		sizes:      sizes,
		done:       make(chan struct{}),
		stopped:    make(chan struct{}),
		lastAt:     time.Now(),
	}
	go s.run()
	return s
}

// stop halts the sampler and waits for the goroutine to exit, so no send can
// race with the closing of progressChan.
func (s *progressSampler) stop() {
	if s == nil {
		return
	}
	s.stopOnce.Do(func() { close(s.done) })
	<-s.stopped
}

func (s *progressSampler) run() {
	defer close(s.stopped)
	ticker := time.NewTicker(progressSampleInterval)
	defer ticker.Stop()
	for {
		select {
		case <-s.done:
			return
		case <-ticker.C:
			mu.Lock()
			c := activeClient
			mu.Unlock()
			if c == nil {
				continue
			}
			ev, ok := s.sample(c)
			if !ok {
				continue
			}
			// Drop the sample when the consumer is behind rather than block.
			select {
			case progressChan <- ev:
			default:
			}
		}
	}
}

// sample builds one progress event. ok is false when the read hit a torn
// value; callers should simply skip that tick.
func (s *progressSampler) sample(c *croc.Client) (ev progressEvent, ok bool) {
	defer func() {
		if r := recover(); r != nil {
			ok = false
		}
	}()

	idx := c.FilesToTransferCurrentNum
	n := len(c.FilesToTransfer)

	totalSize := s.totalSize
	totalFiles := s.totalFiles
	sizes := s.sizes
	if sizes == nil || totalSize == 0 {
		if n > 0 {
			if sizes == nil {
				sizes = make([]int64, n)
				for i := 0; i < n; i++ {
					sizes[i] = c.FilesToTransfer[i].Size
				}
				// Cache for subsequent ticks.
				s.sizes = sizes
			}
			if totalSize == 0 {
				var sum int64
				for _, size := range sizes {
					sum += size
				}
				totalSize = sum
				s.totalSize = sum
			}
		}
	}
	if totalFiles == 0 {
		totalFiles = c.TotalNumberOfContents
		if totalFiles == 0 {
			totalFiles = n
		}
		s.totalFiles = totalFiles
	}

	// TotalSent counts only the current file, so add up the ones already done.
	var done int64
	for i := 0; i < idx && i < len(sizes); i++ {
		done += sizes[i]
	}
	transferred := done + c.TotalSent

	now := time.Now()
	elapsed := now.Sub(s.lastAt).Seconds()
	var speed float64
	if elapsed > 0 && transferred >= s.lastSent {
		speed = float64(transferred-s.lastSent) / elapsed
	}
	s.lastSent, s.lastAt = transferred, now

	currentFile := ""
	if idx >= 0 && idx < n {
		currentFile = filepath.Base(c.FilesToTransfer[idx].Name)
	}

	return progressEvent{
		Type:             eventTypeProgress,
		TransferID:       s.transferID,
		TotalFiles:       totalFiles,
		TotalSize:        totalSize,
		TransferredSize:  transferred,
		CurrentFile:      currentFile,
		CurrentFileIndex: idx + 1,
		Speed:            speed,
	}, true
}

func doSend(paths []string, code string, opts sendOptions, transferID string) {
	// Handle text mode: write text content to a temp file.
	// croc recognises the "croc-stdin-" prefix as stdin/text content.
	sendingText := opts.SendingText && opts.TextContent != ""
	if sendingText {
		// croc v11.5+ validates text offers on the receiver. Reject oversized
		// payloads here so the user gets a clear local error instead of a
		// failed transfer ("text transfer size must be between 1 byte and 1 MiB").
		if n := len(opts.TextContent); n > maxTextTransferBytes {
			progressChan <- progressEvent{Type: 3, TransferID: transferID, Error: fmt.Sprintf(
				"text too large: %d bytes (croc limit is %d bytes / 1 MiB)", n, maxTextTransferBytes)}
			return
		}
		tmpDir := opts.TempDir
		tmpFile, err := os.CreateTemp(tmpDir, "croc-stdin-*.txt")
		if err != nil {
			progressChan <- progressEvent{Type: 3, TransferID: transferID, Error: fmt.Sprintf("temp file: %s", err)}
			return
		}
		defer os.Remove(tmpFile.Name())
		if _, err := tmpFile.WriteString(opts.TextContent); err != nil {
			progressChan <- progressEvent{Type: 3, TransferID: transferID, Error: fmt.Sprintf("write text: %s", err)}
			return
		}
		tmpFile.Close()
		paths = []string{tmpFile.Name()}
	}

	// Ensure we have at least one path
	if len(paths) == 0 {
		progressChan <- progressEvent{Type: 3, TransferID: transferID, Error: "no files to send"}
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
	}

	progressChan <- progressEvent{
		Type:       4,
		TransferID: transferID,
		CodePhrase: code,
	}

	c, err := croc.New(crocOpts)
	if err != nil {
		progressChan <- progressEvent{Type: 3, TransferID: transferID, Error: err.Error()}
		return
	}

	// croc.New(Quiet) sent stderr to DevNull; restore + capture it so we can
	// surface croc v11 reconnect notices as status events.
	restoreStderr := captureStderr(transferID)
	defer restoreStderr()

	mu.Lock()
	activeClient = c
	mu.Unlock()
	defer func() { mu.Lock(); activeClient = nil; mu.Unlock() }()

	filesInfo, emptyFolders, totalFolders, err := croc.GetFilesInfo(
		paths, crocOpts.ZipFolder, crocOpts.GitIgnore, opts.Exclude,
	)
	if err != nil {
		progressChan <- progressEvent{Type: 3, TransferID: transferID, Error: err.Error()}
		return
	}

	var totalSize int64
	sizes := make([]int64, 0, len(filesInfo))
	for _, f := range filesInfo {
		totalSize += f.Size
		sizes = append(sizes, f.Size)
	}

	// Emit live progress while croc moves the data.
	sampler := startProgressSampler(transferID, totalSize, len(filesInfo), sizes)
	defer sampler.stop()

	err = c.Send(filesInfo, emptyFolders, totalFolders)
	if err != nil {
		progressChan <- progressEvent{Type: 3, TransferID: transferID, Error: err.Error()}
		return
	}

	progressChan <- progressEvent{
		Type: 2, TransferID: transferID,
		TotalFiles: len(filesInfo), TotalSize: totalSize,
	}
}

func doReceive(code string, opts receiveOptions, transferID string) {
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
	// (croc.go:3424 -> askReceiveOverwrite); a GUI has nothing on stdin, the
	// read returns empty, the answer is read as "no", and croc `continue`s —
	// the file is silently dropped. Renaming is the only lossless choice that
	// needs no user interaction.
	rename := true
	if opts.Rename != nil {
		rename = *opts.Rename
	}

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

	c, err := croc.New(crocOpts)
	if err != nil {
		progressChan <- progressEvent{Type: 3, TransferID: transferID, Error: err.Error()}
		return
	}

	// croc.New(Quiet) sent stderr to DevNull; restore + capture it so we can
	// surface croc v11 reconnect notices as status events.
	restoreStderr := captureStderr(transferID)
	defer restoreStderr()

	mu.Lock()
	activeClient = c
	mu.Unlock()
	defer func() { mu.Lock(); activeClient = nil; mu.Unlock() }()

	if opts.OutputPath != "" {
		os.Chdir(opts.OutputPath)
	}

	// Signal that transfer has started (type 4 — mirrors doSend)
	progressChan <- progressEvent{
		Type:       4,
		TransferID: transferID,
	}

	// Emit live progress while croc moves the data. The receiver learns the
	// file manifest during the handshake, so sizes/counts are derived from the
	// client (pass 0 / nil).
	sampler := startProgressSampler(transferID, 0, 0, nil)
	defer sampler.stop()

	// Capture stdout during receive — croc echoes the text payload to stdout
	// when SendingText is true, then `transfer()` deletes the received file
	// (`if c.Options.Stdout && !c.Options.IsSender { root.Remove(pathToFile) }`,
	// croc v11.5.2). By capturing stdout we get the text without modifying
	// croc source.
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
		progressChan <- progressEvent{Type: 3, TransferID: transferID, Error: err.Error()}
		return
	}

	// Collect received file info
	var totalSize int64
	var fileNames []string
	var isText bool
	var textContent string

	// Detect text receive: `c.Options.SendingText` is reliably set by the
	// receiver from the sender's info (croc.go `processSenderInfo`:
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

	progressChan <- progressEvent{
		Type:        2,
		TransferID:  transferID,
		TotalFiles:  len(fileNames),
		TotalSize:   totalSize,
		CurrentFile: strings.Join(fileNames, "\n"),
		IsText:      isText,
		TextContent: textContent,
	}
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

// Fallback relay addresses used when models.DEFAULT_RELAY / DEFAULT_RELAY6
// resolve to empty (e.g. DNS failure during croc's init()).
// Port is intentionally omitted — croc defaults to DEFAULT_PORT (9009) and
// the relay banner overrides RelayPorts after connection.
const fallbackRelay = "croc.schollz.com"
const fallbackRelay6 = "croc6.schollz.com"

func main() {} // required for c-shared builds
