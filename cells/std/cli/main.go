package main

import (
	"fmt"
	"log"
	"os"
	"os/exec"
	"strings"
	"syscall"

	tea "github.com/charmbracelet/bubbletea"

	"github.com/divnix/std/env"
)

var buildVersion = "dev"
var buildCommit = "dirty"

func bashExecve(command []string, cmdArgs []string) error {
	binary, err := exec.LookPath("bash")
	if err != nil {
		return err
	}
	_, _, _, lastActionPath, err := env.SetEnv()
	if err != nil {
		return err
	}
	env := os.Environ()
	args := []string{"bash", "-c", fmt.Sprintf(
		"%s && %s %s",
		strings.Join(command, " "),
		lastActionPath,
		strings.Join(cmdArgs, " "),
	),
	}
	if err := syscall.Exec(binary, args, env); err != nil {
		return err
	}
	return nil
}

func main() {
	if len(os.Args[1:]) == 0 {
		// with NO arguments, invoke the TUI
		if model, err := tea.NewProgram(
			InitialPage(),
			tea.WithAltScreen(),
		).StartReturningModel(); err != nil {
			log.Fatalf("Error running program: %s", err)
		} else if err := model.(*Tui).FatalError; err != nil {
			log.Fatal(err)
		} else if command := model.(*Tui).ExecveCommand; command != nil {
			// TUI can't pass arguments to (task-runner type) actions
			if err := bashExecve(command, []string{}); err != nil {
				log.Fatal(err)
			}
		}
	} else {
		// with arguments, invoke the CLI
		ExecuteCli()
	}
}
