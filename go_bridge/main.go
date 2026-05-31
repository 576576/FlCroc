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
	"encoding/json"
	"fmt"
	"io"
	"os"
	"path/filepath"
	"strings"
	"sync"
	"time"
	"unsafe"

	"github.com/schollz/croc/v10/src/croc"
	"github.com/schollz/croc/v10/src/models"
	"github.com/schollz/croc/v10/src/utils"
)

// ── Global state ────────────────────────────────────────────
var (
	mu           sync.Mutex
	activeClient *croc.Client
	progressChan chan progressEvent
)

type progressEvent struct {
	Type            int     `json:"type"`
	TransferID      string  `json:"transfer_id"`
	TotalFiles      int     `json:"total_files"`
	TotalSize       int64   `json:"total_size"`
	TransferredSize int64   `json:"transferred_size"`
	CurrentFile     string  `json:"current_file"`
	Speed           float64 `json:"speed"`
	CodePhrase      string  `json:"code_phrase"`
	Error           string  `json:"error"`
	IsText          bool    `json:"is_text"`
	TextContent     string  `json:"text_content"`
}

// ── Exported C API ──────────────────────────────────────────

//export CrocGetVersion
func CrocGetVersion() *C.char {
	return C.CString("croc v10.4.4")
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

	progressChan = make(chan progressEvent, 100)

	go func() {
		defer close(progressChan)
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
	progressChan = make(chan progressEvent, 100)

	go func() {
		defer close(progressChan)
		doReceive(C.GoString(codePhrase), opts, transferID)
	}()

	return marshalResult(transferID, "")
}

//export CrocPollProgress
func CrocPollProgress() *C.char {
	if progressChan == nil {
		return marshalEvent(nil)
	}
	select {
	case ev, ok := <-progressChan:
		if !ok {
			// Channel closed — return completed sentinel.
			progressChan = nil
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

// pollProgress reads croc's internal TotalSent counter every 200ms and sends
// type-1 progress events to progressChan. Stops when done is closed.
// If totalSize is 0, it is computed from activeClient.FilesToTransfer.
func pollProgress(done <-chan struct{}, totalSize int64, transferID string) {
	ticker := time.NewTicker(200 * time.Millisecond)
	defer ticker.Stop()
	for {
		select {
		case <-done:
			return
		case <-ticker.C:
			mu.Lock()
			c := activeClient
			mu.Unlock()
			if c == nil {
				continue
			}
			ts := totalSize
			if ts == 0 {
				for _, f := range c.FilesToTransfer {
					ts += f.Size
				}
			}
			if ts == 0 {
				continue // no size info yet → skip this tick
			}
			progressChan <- progressEvent{
				Type:            1,
				TransferID:      transferID,
				TotalSize:       ts,
				TransferredSize: c.TotalSent,
			}
		}
	}
}

func doSend(paths []string, code string, opts sendOptions, transferID string) {
	// Handle text mode: write text content to a temp file.
	// croc recognises the "croc-stdin-" prefix as stdin/text content.
	sendingText := opts.SendingText && opts.TextContent != ""
	if sendingText {
		tmpFile, err := os.CreateTemp("", "croc-stdin-*.txt")
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
	relayAddr6 := opts.RelayAddress6
	if relayAddr6 == "" {
		relayAddr6 = models.DEFAULT_RELAY6
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

	crocOpts := croc.Options{
		IsSender:      true,
		SharedSecret:  code,
		Debug:         false,
		RelayAddress:  relayAddr,
		RelayAddress6: relayAddr6,
		RelayPorts:    relayPorts,
		RelayPassword: relayPass,
		NoPrompt:      true,
		DisableLocal:  opts.DisableLocal,
		OnlyLocal:     opts.OnlyLocal,
		Curve:         curve,
		HashAlgorithm: hashAlgo,
		NoCompress:    opts.NoCompress,
		Overwrite:     opts.Overwrite,
		ZipFolder:     opts.ZipFolder,
		GitIgnore:     opts.GitIgnore,
		SendingText:   sendingText,
		Quiet:         true,
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
	for _, f := range filesInfo {
		totalSize += f.Size
	}

	progressChan <- progressEvent{
		Type: 1, TransferID: transferID,
		TotalFiles: len(filesInfo), TotalSize: totalSize,
	}

	// Start progress poller during transfer
	pollDone := make(chan struct{})
	var pollWg sync.WaitGroup
	pollWg.Add(1)
	go func() {
		defer pollWg.Done()
		pollProgress(pollDone, totalSize, transferID)
	}()

	err = c.Send(filesInfo, emptyFolders, totalFolders)

	close(pollDone) // signal poller to stop
	pollWg.Wait()   // ensure poller goroutine exited

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

	crocOpts := croc.Options{
		IsSender:      false,
		SharedSecret:  code,
		Debug:         false,
		RelayAddress:  relayAddr,
		RelayAddress6: models.DEFAULT_RELAY6,
		RelayPorts:    relayPorts,
		RelayPassword: relayPass,
		NoPrompt:      true,
		OnlyLocal:     opts.OnlyLocal,
		Curve:         curve,
		HashAlgorithm: hashAlgo,
		Overwrite:     opts.Overwrite,
		Quiet:         true,
	}

	c, err := croc.New(crocOpts)
	if err != nil {
		progressChan <- progressEvent{Type: 3, TransferID: transferID, Error: err.Error()}
		return
	}

	mu.Lock()
	activeClient = c
	mu.Unlock()
	defer func() { mu.Lock(); activeClient = nil; mu.Unlock() }()

	if opts.OutputPath != "" {
		os.Chdir(opts.OutputPath)
	}

	// Start progress poller during transfer (totalSize computed dynamically from croc)
	pollDone := make(chan struct{})
	var pollWg sync.WaitGroup
	pollWg.Add(1)
	go func() {
		defer pollWg.Done()
		pollProgress(pollDone, 0, transferID)
	}()

	// Capture stdout during receive — croc prints text content to stdout
	// when SendingText is true (and then deletes the temp file).
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

	close(pollDone) // signal poller to stop
	pollWg.Wait()   // ensure poller goroutine exited

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
	// receiver from the sender's info (croc.go processMessageFileInfo L1305).
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

func main() {} // required for c-shared builds
