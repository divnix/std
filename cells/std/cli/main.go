package main

import (
	"fmt"
	"log"
	"os"
	"os/exec"
	"strings"
	"syscall"

	tea "github.com/charmbracelet/bubbletea"
)

func bashExecve(command []string) error {
	binary, err := exec.LookPath("bash")
	if err != nil {
		return err
	}
	args := []string{"bash", "-c", fmt.Sprintf("%s && ./.std/last-action", strings.Join(command, " "))}
	env := os.Environ()
	if err := syscall.Exec(binary, args, env); err != nil {
		return err
	}
	return nil
}

func main() {

	if model, err := tea.NewProgram(InitialPage()).StartReturningModel(); err != nil {
		log.Fatalf("Error running program: %s", err)
	} else if err := model.(*Tui).FatalError; err != nil {
		log.Fatal(err)
	} else if command := model.(*Tui).ExecveCommand; command != nil {
		if err := bashExecve(command); err != nil {
			log.Fatal(err)
		}
	}
}
