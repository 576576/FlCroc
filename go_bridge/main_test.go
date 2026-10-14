package main

import (
	"errors"
	"strings"
	"testing"

	"github.com/schollz/croc/v11/src/croc"
)

// normalizeThrottle guards a panic: croc parses Options.ThrottleUpload itself
// and panics on anything it cannot read, which inside a c-shared library takes
// the host Flutter process down. Anything that is not a plain positive integer
// with an optional k/m/g suffix must therefore be rejected here.
func TestNormalizeThrottle(t *testing.T) {
	valid := []string{"500k", "5M", "1G", "1048576", " 500k ", "1m"}
	for _, in := range valid {
		got, err := normalizeThrottle(in)
		if err != nil {
			t.Errorf("normalizeThrottle(%q) unexpected error: %v", in, err)
			continue
		}
		if got == "" {
			t.Errorf("normalizeThrottle(%q) = %q, want a non-empty limit", in, got)
		}
	}

	// "" is the documented "no limit" spelling.
	if got, err := normalizeThrottle(""); err != nil || got != "" {
		t.Errorf(`normalizeThrottle("") = (%q, %v), want ("", nil)`, got, err)
	}

	// Zero would make croc divide by zero when building its rate limiter, so it
	// degrades to "no limit" instead of being passed through or rejected.
	for _, in := range []string{"0", "0k", "0M"} {
		if got, err := normalizeThrottle(in); err != nil || got != "" {
			t.Errorf("normalizeThrottle(%q) = (%q, %v), want (\"\", nil)", in, got, err)
		}
	}

	// These would all panic inside croc.
	invalid := []string{"abc", "5kb", "k", "-1k", "5.5m", "1 000", "500kk", "1e6"}
	for _, in := range invalid {
		if _, err := normalizeThrottle(in); err == nil {
			t.Errorf("normalizeThrottle(%q) accepted an invalid limit", in)
		}
	}
}

func TestParseRelayPorts(t *testing.T) {
	got := parseRelayPorts("9009,9010")
	if len(got) != 2 || got[0] != "9009" || got[1] != "9010" {
		t.Errorf("parseRelayPorts(\"9009,9010\") = %v", got)
	}

	// Empty / all-blank input falls back to the default range.
	for _, in := range []string{"", "  ", ",,,"} {
		got := parseRelayPorts(in)
		if len(got) != 5 || got[0] != "9009" {
			t.Errorf("parseRelayPorts(%q) = %v, want the default range", in, got)
		}
	}
}

// scanNotices replaces a bufio.Scanner, which stopped reading for good once a
// line exceeded 64 KiB. croc's progress bar only ends a line when a file
// completes, so a single large file used to wedge the stderr pipe and hang the
// transfer with no error anywhere.
func TestScanNotices(t *testing.T) {
	s := &session{}

	// A notice split across two chunks is still recognised.
	carry := scanNotices("...detected a transfer interru", s)
	carry = scanNotices(carry+"ption. Retrying securely...\n", s)
	if carry != "" {
		t.Errorf("carry = %q, want empty after a terminated line", carry)
	}

	// An unterminated tail stays bounded: 200 KiB of progress-bar redraws must
	// not pile up in memory.
	for i := 0; i < 50; i++ {
		carry = scanNotices(carry+strings.Repeat("x", 4096), s)
	}
	if len(carry) > 8192 {
		t.Errorf("carry grew to %d bytes, want it bounded", len(carry))
	}
}

// The sampler and the stderr reader outlive the transfer goroutine by a tick,
// so emitting after the channel is closed must drop the event, not panic.
func TestSessionEmitAfterClose(t *testing.T) {
	s := &session{id: "7", events: make(chan progressEvent, 1)}
	s.emit(progressEvent{Type: eventTypeProgress})
	if got := <-s.events; got.TransferID != "7" {
		t.Errorf("TransferID = %q, want %q", got.TransferID, "7")
	}

	s.closeEvents()
	s.emit(progressEvent{Type: eventTypeProgress})
	s.emit(progressEvent{Type: eventTypeProgress})
	if _, ok := <-s.events; ok {
		t.Error("received an event from a closed session")
	}
}

// A second transfer used to steal the first one's event channel.
func TestNewSessionSingleFlight(t *testing.T) {
	first, err := newSession()
	if err != nil {
		t.Fatalf("newSession: %v", err)
	}
	if _, err := newSession(); !errors.Is(err, errTransferInProgress) {
		t.Errorf("second newSession error = %v, want errTransferInProgress", err)
	}

	first.markFinished()
	second, err := newSession()
	if err != nil {
		t.Fatalf("newSession after finish: %v", err)
	}
	if second.id == first.id {
		t.Errorf("second session reused the id %q", second.id)
	}
	second.markFinished()
}

// Dart draws the matrix itself, so a mis-strided or truncated one shows up as a
// broken QR code rather than as an error.
func TestQRMatrix(t *testing.T) {
	const text = "https://getcroc.com/?code=bold-cat-1234"

	size, modules, err := qrMatrix(text)
	if err != nil {
		t.Fatalf("qrMatrix: %v", err)
	}
	if len(modules) != size*size {
		t.Fatalf("len(modules) = %d, want %d", len(modules), size*size)
	}
	for i := 0; i < len(modules); i++ {
		if modules[i] != '0' && modules[i] != '1' {
			t.Fatalf("modules[%d] = %q, want '0' or '1'", i, modules[i])
		}
	}

	// go-qrcode renders the symbol inside a quiet zone. Find it by walking the
	// diagonal instead of hardcoding the border width, so bumping the library
	// only fails here if the matrix is genuinely malformed.
	quiet := 0
	for quiet < size && modules[quiet*size+quiet] != '1' {
		quiet++
	}
	symbol := size - 2*quiet
	// Every QR symbol is 1 mod 4 modules wide (21, 25, 29, …).
	if symbol < 21 || (symbol-1)%4 != 0 {
		t.Fatalf("size = %d, quiet = %d: symbol = %d, want 1 mod 4 and >= 21", size, quiet, symbol)
	}

	// Locate the three finder patterns: each has a dark outer corner and a dark
	// 3x3 centre, separated by a light ring. A wrong stride or a dropped row
	// shows up here.
	for _, c := range [][2]int{
		{quiet, quiet},
		{quiet, quiet + symbol - 7},
		{quiet + symbol - 7, quiet},
	} {
		if modules[c[0]*size+c[1]] != '1' {
			t.Errorf("finder corner %v is not dark", c)
		}
	}
	if modules[(quiet+3)*size+quiet+3] != '1' {
		t.Error("top-left finder centre is not dark")
	}
	if modules[(quiet+1)*size+quiet+1] != '0' {
		t.Error("top-left finder ring is not light")
	}

	if _, again, err := qrMatrix(text); err != nil || again != modules {
		t.Error("qrMatrix is not deterministic for the same input")
	}
	if _, _, err := qrMatrix(""); err == nil {
		t.Error(`qrMatrix("") accepted empty text`)
	}
}

// The sender's QR must carry the URL croc itself would show, or a phone that
// scans it lands somewhere else than `croc --qr` sends it.
func TestQRMatrixEncodesWebReceiveURL(t *testing.T) {
	url := croc.WebReceiveURL("bold-cat-1234")
	if !strings.Contains(url, "bold-cat-1234") {
		t.Fatalf("WebReceiveURL = %q, want it to carry the share code", url)
	}
	if _, modules, err := qrMatrix(url); err != nil || modules == "" {
		t.Fatalf("qrMatrix(WebReceiveURL(...)) = %v, want a matrix", err)
	}

	// A code that needs escaping must still produce a usable URL. A '+' is fine
	// (it is how QueryEscape writes a space); a bare space or fragment is not.
	if escaped := croc.WebReceiveURL("a b/c+d"); strings.ContainsAny(escaped, " #") {
		t.Errorf("WebReceiveURL = %q, want the code escaped", escaped)
	}
}
