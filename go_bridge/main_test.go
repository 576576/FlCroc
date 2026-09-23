package main

import "testing"

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
