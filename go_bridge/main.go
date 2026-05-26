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
	"encoding/json"
	"fmt"
	"os"
	"sync"
	"unsafe"

	"github.com/schollz/croc/v10/src/croc"
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
			progressChan = nil
			return marshalEvent(nil)
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
		// croc.Client does not support cancellation natively;
		// we rely on process kill from the Dart side
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

func doSend(paths []string, code string, opts sendOptions, transferID string) {
	// Handle text mode: write text content to a temp file
	if opts.SendingText && opts.TextContent != "" {
		tmpFile, err := os.CreateTemp("", "flcroc-text-*.txt")
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
	crocOpts := croc.Options{
		IsSender:      true,
		SharedSecret:  code,
		Debug:         false,
		RelayAddress:  opts.RelayAddress,
		RelayPorts:    defaultRelayPorts(),
		RelayPassword: opts.RelayPassword,
		NoPrompt:      true,
		DisableLocal:  opts.DisableLocal,
		OnlyLocal:     opts.OnlyLocal,
		Curve:         opts.Curve,
		HashAlgorithm: opts.HashAlgorithm,
		NoCompress:    opts.NoCompress,
		Overwrite:     opts.Overwrite,
		ZipFolder:     opts.ZipFolder,
		GitIgnore:     opts.GitIgnore,
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
	crocOpts := croc.Options{
		IsSender:      false,
		SharedSecret:  code,
		Debug:         false,
		RelayAddress:  opts.RelayAddress,
		RelayPorts:    defaultRelayPorts(),
		RelayPassword: opts.RelayPassword,
		NoPrompt:      true,
		OnlyLocal:     opts.OnlyLocal,
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

	err = c.Receive()
	if err != nil {
		progressChan <- progressEvent{Type: 3, TransferID: transferID, Error: err.Error()}
		return
	}

	progressChan <- progressEvent{Type: 2, TransferID: transferID}
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
	RelayPassword string   `json:"relay_password"`
	Exclude       []string `json:"exclude"`
	SendingText   bool     `json:"sending_text"`
	TextContent   string   `json:"text_content"`
}

type receiveOptions struct {
	Overwrite     bool   `json:"overwrite"`
	OnlyLocal     bool   `json:"only_local"`
	OutputPath    string `json:"output_path"`
	RelayAddress  string `json:"relay_address"`
	RelayPassword string `json:"relay_password"`
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

func main() {} // required for c-shared builds
