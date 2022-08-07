package main

import (
	"bytes"
	"fmt"
	"log"
	"os"
	"os/exec"
	"strings"
	"syscall"

	tea "github.com/charmbracelet/bubbletea"
)

var buildVersion = "dev"
var buildCommit = "dirty"

// PRJ_ROOT is a useful environment contract prototyped by `numtide/devshell`
// TODO: coordinate with `numtide` about PRJ Base Directory Specification
const (
	PRJ_ROOT      = "PRJ_ROOT"
	prjRootGitCmd = "git rev-parse --show-toplevel"
)

func bashExecve(command []string) error {
	binary, err := exec.LookPath("bash")
	if err != nil {
		return err
	}
	var prjRoot string
	prjRoot, present := os.LookupEnv(PRJ_ROOT)
	if !present {
		args := strings.Fields(prjRootGitCmd)
		prjRootB, err := exec.Command(args[0], args[1:]...).Output()
		prjRootB = bytes.TrimRight(prjRootB, "\n")
		prjRoot = string(prjRootB[:])
		if err != nil {
			if exitErr, ok := err.(*exec.ExitError); ok {
				return fmt.Errorf("%w, stderr:\n%s", exitErr, exitErr.Stderr)
			}
			return err
		}

		os.Setenv(PRJ_ROOT, prjRoot)
	}
	env := os.Environ()
	args := []string{"bash", "-c", fmt.Sprintf("%s && %s/.std/last-action", strings.Join(command, " "), prjRoot)}
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
			if err := bashExecve(command); err != nil {
				log.Fatal(err)
			}
		}
	} else {
		// with arguments, invoke the CLI
		ExecuteCli()
	}
}
