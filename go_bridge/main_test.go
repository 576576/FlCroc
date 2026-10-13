package main

import (
	"errors"
	"strings"
	"testing"
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
