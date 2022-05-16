package main

import (
	"encoding/json"
	"fmt"
	"os/exec"

	"github.com/TylerBrock/colorjson"
	tea "github.com/charmbracelet/bubbletea"

	"github.com/divnix/std/data"
)

type outt struct {
	drvPath string            `json:"drvPath"`
	outputs map[string]string `json:"outputs"`
}

var (
	currentSystemArgs    = []string{"eval", "--raw", "--impure", "--expr", "builtins.currentSystem"}
	flakeInitFragment    = "%s#__std.init.%s"
	flakeActionsFragment = "%s#__std.actions.%s.%s.%s.%s.%s"
	flakeEvalJson        = []string{"eval", "--json", "--option", "warn-dirty", "false"}
	flakeEvalRaw         = []string{"eval", "--raw", "--option", "warn-dirty", "false"}
	flakeBuild           = []string{"build", "--out-link", ".std/last-action", "--option", "warn-dirty", "false"}
)

func GetNix() (string, tea.Msg) {
	nix, err := exec.LookPath("nix")
	if err != nil {
		return "", cellLoadingFatalErrf("You need to install 'nix' in order to use 'std'")
	}
	return nix, nil
}

func getCurrentSystem() ([]byte, tea.Msg) {
	// detect the current system
	nix, msg := GetNix()
	if msg != nil {
		return nil, msg
	}
	currentSystem, err := exec.Command(nix, currentSystemArgs...).Output()
	if err != nil {
		if exitErr, ok := err.(*exec.ExitError); ok {
			return nil, cellLoadingFatalErrf("%w, stderr:\n%s", exitErr, exitErr.Stderr)
		}
		return nil, cellLoadingFatalErr(err)
	}
	return currentSystem, nil
}

func getInitEvalCmdArgs() ([]string, tea.Msg) {

	currentSystem, err := getCurrentSystem()
	if err != nil {
		return nil, err
	}
	return append(
		flakeEvalJson, fmt.Sprintf(flakeInitFragment, ".", currentSystem)), nil
}

func GetActionEvalCmdArgs(c, o, t, a string) (string, []string, tea.Msg) {
	nix, msg := GetNix()
	if msg != nil {
		return "", nil, msg
	}

	currentSystem, err := getCurrentSystem()
	if err != nil {
		return "", nil, err
	}
	return nix, append(
		flakeBuild, fmt.Sprintf(flakeActionsFragment, ".", currentSystem, c, o, t, a)), nil
}

func loadFlake() tea.Msg {
	var root data.Root

	nix, msg := GetNix()
	if msg != nil {
		return msg
	}

	args, msg := getInitEvalCmdArgs()
	if msg != nil {
		return msg
	}

	// load the std metadata from the flake
	cmd := exec.Command(nix, args...)
	out, err := cmd.Output()
	if err != nil {
		if exitErr, ok := err.(*exec.ExitError); ok {
			return cellLoadingFatalErrf("command: %s, %w, stderr:\n%s", cmd.String(), exitErr, exitErr.Stderr)
		}
		return cellLoadingFatalErr(err)
	}

	if err := json.Unmarshal(out, &root.Cells); err != nil {
		var obj interface{}
		json.Unmarshal(out, &obj)
		f := colorjson.NewFormatter()
		f.Indent = 2
		s, _ := f.Marshal(obj)
		return cellLoadingFatalErrf("%w - object: %s", err, s)
	}

	// var obj interface{}
	// json.Unmarshal(out, &obj)
	// f := colorjson.NewFormatter()
	// f.Indent = 2
	// s, _ := f.Marshal(obj)
	// log.Fatalf("object: %s", s)

	return cellLoadedMsg{root.Cells}
}

type cellLoadedMsg = data.Root

type cellLoadingFatalErrMsg struct {
	err error
}

func cellLoadingFatalErr(err error) cellLoadingFatalErrMsg {
	return cellLoadingFatalErrMsg{err}
}

func cellLoadingFatalErrf(f string, a ...interface{}) cellLoadingFatalErrMsg {
	return cellLoadingFatalErrMsg{fmt.Errorf(f, a...)}
}
