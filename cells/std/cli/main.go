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
	NIX_CONFIG    = "NIX_CONFIG"
	prjRootGitCmd = "git rev-parse --show-toplevel"
)

// extraNixConfig implements quality of life flags for the nix command invocation
var extraNixConfig = strings.Join([]string{
	// can never occur: actions invoke store path copies of the flake
	// "warn-dirty = false",
	"accept-flake-config = true",
	"builders-use-substitutes = true",
	// TODO: these are unfortunately not available for setting as env flags
	// update-lock-file = false,
	// write-lock-file = false,
}, "\n")

func bashExecve(command []string, cmdArgs []string) error {
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
	nixConfigEnv, present := os.LookupEnv(NIX_CONFIG)
	if !present {
		os.Setenv(NIX_CONFIG, extraNixConfig)
	} else {
		os.Setenv(NIX_CONFIG, fmt.Sprintf("%s\n%s", nixConfigEnv, extraNixConfig))
	}
	env := os.Environ()
	args := []string{"bash", "-c", fmt.Sprintf(
			"%s && %s/.std/last-action %s",
			strings.Join(command, " "),
			prjRoot,
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
