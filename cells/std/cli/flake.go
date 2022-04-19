package main

import (
	"encoding/json"
	"fmt"
	"log"
	"os/exec"

	"github.com/TylerBrock/colorjson"
	tea "github.com/charmbracelet/bubbletea"
	"github.com/charmbracelet/lipgloss"

	"github.com/divnix/std/cells/std/cli/data"
	"github.com/divnix/std/cells/std/cli/dummy_data"
)

var (
	currentSystemArgs    = []string{"eval", "--raw", "--impure", "--expr", "builtins.currentSystem"}
	flakeStdMetaFragment = "%s#__std.%s"
	flakeStdMetaArgs     = []string{"eval", "--json", "--option", "warn-dirty", "false"}
)

func fakeData() []data.Item {
	var targetsGenerator dummy_data.RandomItemGenerator
	const numItems = 24
	items := make([]data.Item, numItems)
	for i := 0; i < numItems; i++ {
		items[i] = targetsGenerator.Next()
	}
	return items
}

func loadFlake() tea.Msg {
	var items []data.Item
	nix, err := exec.LookPath("nix")
	if err != nil {
		log.Fatal("You need to install 'nix' in order to use 'std'")
	}

	// detect the current system
	currentSystem, err := exec.Command(nix, currentSystemArgs...).Output()
	if err != nil {
		if exitErr, ok := err.(*exec.ExitError); ok {
			log.Fatalln(exitErr, string(exitErr.Stderr))
		}
		log.Fatal(err)
	}

	flakeStdMetaFragment = fmt.Sprintf(flakeStdMetaFragment, ".", currentSystem)
	flakeStdMetaArgs = append(flakeStdMetaArgs, flakeStdMetaFragment)

	// load the std metadata from the flake
	cmd := exec.Command(nix, flakeStdMetaArgs...)
	flakeStdMeta, err := cmd.Output()
	if err != nil {
		switch exitErr := err.(type) {
		case *exec.ExitError:
			return exitErrMsg{
				cmd: cmd.String(),
				err: exitErr,
			}
		default:
			log.Fatal(err)
		}
	}

	if err := json.Unmarshal(flakeStdMeta, &items); err != nil {
		var obj interface{}
		json.Unmarshal(flakeStdMeta, &obj)
		f := colorjson.NewFormatter()
		f.Indent = 2
		s, _ := f.Marshal(obj)
		log.Fatalf("%s - object: %s", err, s)
	}

	// var obj interface{}
	// json.Unmarshal(flakeStdMeta, &obj)
	// f := colorjson.NewFormatter()
	// f.Indent = 2
	// s, _ := f.Marshal(obj)
	// log.Fatalf("object: %s", s)

	return flakeLoadedMsg{
		// Items: fakeData(),
		Items: items,
	}
}

type flakeLoadedMsg struct {
	Items []data.Item
}

type exitErrMsg struct {
	cmd string
	err *exec.ExitError
}

func (e exitErrMsg) Error() string {
	return fmt.Sprintf(
		"%s\nresulted in %s\n\nTraceback:\n\n%s",
		lipgloss.NewStyle().Faint(true).Bold(true).Render(e.cmd),
		e.err.Error(),
		string(e.err.Stderr),
	)
}
