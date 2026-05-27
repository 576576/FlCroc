package main

import (
	"fmt"
	"os"

	"github.com/schollz/croc/v10/src/croc"
	"github.com/schollz/croc/v10/src/models"
)

func main() {
	if len(os.Args) < 2 {
		fmt.Fprintf(os.Stderr, "Usage: go run . <code-phrase>\n")
		os.Exit(1)
	}
	code := os.Args[1]

	opts := croc.Options{
		IsSender:      false,
		SharedSecret:  code,
		Debug:         true,
		RelayAddress:  models.DEFAULT_RELAY,
		RelayAddress6: models.DEFAULT_RELAY6,
		RelayPorts:    defaultRelayPorts(),
		RelayPassword: models.DEFAULT_PASSPHRASE,
		NoPrompt:      true,
		OnlyLocal:     false,
		Curve:         "p256",
		Overwrite:     true,
		Quiet:         false,
	}

	c, err := croc.New(opts)
	if err != nil {
		fmt.Fprintf(os.Stderr, "croc.New: %s\n", err)
		os.Exit(1)
	}

	fmt.Printf("Waiting for sender with code: %s\n", code)
	err = c.Receive()
	if err != nil {
		fmt.Fprintf(os.Stderr, "\nReceive failed: %s\n", err)
		os.Exit(1)
	}
	fmt.Println("\n✓ Received successfully")
}

func defaultRelayPorts() []string {
	const startPort = 9009
	const numPorts = 5
	ports := make([]string, numPorts)
	for i := 0; i < numPorts; i++ {
		ports[i] = fmt.Sprintf("%d", startPort+i)
	}
	return ports
}
