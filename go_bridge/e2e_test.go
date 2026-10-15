package main

// End-to-end coverage for the bridge's own transfer path, driven against the
// croc CLI. Needs a croc binary built from submodules/croc:
//
//	go build -o build/_croc.exe .          # from submodules/croc
//	FL_CROC_E2E=1 go test -run TestE2E -count=1 ./go_bridge
//
// It is skipped unless FL_CROC_E2E is set, so the normal test run stays fast
// and does not need a relay or a peer binary. FL_CROC_E2E_BIN overrides the
// binary path.
//
// TestE2EAppSendsToCLI is the regression test for a probe desync: the receiver
// probes for the sender's LAN addresses with a deadline, the sender can only
// answer once its own relay route is up, and an answer that arrives after the
// deadline used to be read by the message loop as a compressed frame — the
// transfer died with "flate: corrupt input before offset 6".

import (
	"encoding/json"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
	"testing"
	"time"
)

const (
	e2eRelayAddress = "127.0.0.1:19309"
	e2eRelayPort    = "19309"
)

func e2eSkip(t *testing.T) string {
	t.Helper()
	if os.Getenv("FL_CROC_E2E") == "" {
		t.Skip("set FL_CROC_E2E=1 to run the bridge end-to-end tests")
	}
	bin := os.Getenv("FL_CROC_E2E_BIN")
	if bin == "" {
		bin = filepath.Join("..", "build", "_croc.exe")
	}
	if _, err := os.Stat(bin); err != nil {
		t.Skipf("croc binary not found at %s (%v); build it with "+
			"`go build -o ../../build/_croc.exe .` from submodules/croc", bin, err)
	}
	return bin
}

// e2eEnv drops the proxy variables: croc's CLI reads HTTP_PROXY for --connect,
// so leaving them set would route the relay dial through a proxy.
func e2eEnv() []string {
	var out []string
	for _, kv := range os.Environ() {
		key, _, _ := strings.Cut(kv, "=")
		switch strings.ToLower(key) {
		case "http_proxy", "https_proxy", "no_proxy":
			continue
		}
		out = append(out, kv)
	}
	return out
}

func startRelay(t *testing.T, bin string) *exec.Cmd {
	t.Helper()
	cmd := exec.Command(bin, "relay", "--port", e2eRelayPort, "--transfers", "2")
	cmd.Env = e2eEnv()
	cmd.Stdout, cmd.Stderr = os.Stdout, os.Stderr
	if err := cmd.Start(); err != nil {
		t.Fatalf("start relay: %v", err)
	}
	time.Sleep(3 * time.Second)
	return cmd
}

// drainEvents collects the session's events until it closes or the timeout hits.
func drainEvents(s *session, timeout time.Duration) []progressEvent {
	var out []progressEvent
	deadline := time.After(timeout)
	for {
		select {
		case ev, ok := <-s.events:
			if !ok {
				return out
			}
			out = append(out, ev)
		case <-deadline:
			return out
		}
	}
}

func reportEvents(t *testing.T, evs []progressEvent) {
	t.Helper()
	b, _ := json.Marshal(evs)
	t.Logf("events (%d): %s", len(evs), b)
}

func TestE2EAppReceivesFromCLI(t *testing.T) {
	bin := e2eSkip(t)
	relay := startRelay(t, bin)
	defer relay.Process.Kill()

	outDir := t.TempDir()
	srcDir := t.TempDir()
	payload := filepath.Join(srcDir, "payload.txt")
	if err := os.WriteFile(payload, []byte("hello from cli\n"), 0o644); err != nil {
		t.Fatal(err)
	}
	code := "1234-e2e-app-rcv"

	sender := exec.Command(bin, "--relay", e2eRelayAddress, "--yes", "send", "--code", code, payload)
	sender.Env = e2eEnv()
	sender.Stdout, sender.Stderr = os.Stdout, os.Stderr
	if err := sender.Start(); err != nil {
		t.Fatalf("start sender: %v", err)
	}
	defer sender.Process.Kill()
	time.Sleep(time.Second)

	s, err := newSession()
	if err != nil {
		t.Fatalf("newSession: %v", err)
	}
	s.run(func(s *session) {
		doReceive(s, code, receiveOptions{RelayAddress: e2eRelayAddress, OutputPath: outDir})
	})
	reportEvents(t, drainEvents(s, 45*time.Second))

	got, err := os.ReadFile(filepath.Join(outDir, "payload.txt"))
	if err != nil {
		t.Fatalf("payload not received: %v", err)
	}
	if string(got) != "hello from cli\n" {
		t.Fatalf("payload mismatch: %q", got)
	}
}

func TestE2EAppSendsToCLI(t *testing.T) {
	bin := e2eSkip(t)
	relay := startRelay(t, bin)
	defer relay.Process.Kill()

	srcDir := t.TempDir()
	outDir := t.TempDir()
	payload := filepath.Join(srcDir, "payload.txt")
	if err := os.WriteFile(payload, []byte("hello from app\n"), 0o644); err != nil {
		t.Fatal(err)
	}
	code := "1234-e2e-app-snd"

	logPath := filepath.Join(srcDir, "receiver.log")
	logFile, err := os.Create(logPath)
	if err != nil {
		t.Fatal(err)
	}
	defer logFile.Close()

	// The receiver has to be up first: that is what makes it probe before the
	// sender's route is ready, which is the ordering this test pins down.
	recv := exec.Command(bin, "--relay", e2eRelayAddress, "--yes", "--debug", "--out", outDir, code)
	recv.Env = e2eEnv()
	recv.Stdout, recv.Stderr = logFile, logFile
	if err := recv.Start(); err != nil {
		t.Fatalf("start receiver: %v", err)
	}
	defer recv.Process.Kill()
	time.Sleep(time.Second)

	s, err := newSession()
	if err != nil {
		t.Fatalf("newSession: %v", err)
	}
	s.run(func(s *session) {
		doSend(s, []string{payload}, code, sendOptions{RelayAddress: e2eRelayAddress})
	})
	reportEvents(t, drainEvents(s, 45*time.Second))

	time.Sleep(2 * time.Second)
	if log, err := os.ReadFile(logPath); err == nil {
		lines := strings.Split(strings.TrimRight(string(log), "\n"), "\n")
		if len(lines) > 25 {
			lines = lines[len(lines)-25:]
		}
		t.Logf("receiver log (tail):\n%s", strings.Join(lines, "\n"))
	}
	got, err := os.ReadFile(filepath.Join(outDir, "payload.txt"))
	if err != nil {
		t.Fatalf("payload not received: %v", err)
	}
	if string(got) != "hello from app\n" {
		t.Fatalf("payload mismatch: %q", got)
	}
}
