package main

import (
	"encoding/json"
	"errors"
	"fmt"
	"os/exec"

	"github.com/TylerBrock/colorjson"

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

func GetNix() (string, error) {
	nix, err := exec.LookPath("nix")
	if err != nil {
		return "", errors.New("You need to install 'nix' in order to use 'std'")
	}
	return nix, nil
}

func getCurrentSystem() ([]byte, error) {
	// detect the current system
	nix, err := GetNix()
	if err != nil {
		return nil, err
	}
	currentSystem, err := exec.Command(nix, currentSystemArgs...).Output()
	if err != nil {
		if exitErr, ok := err.(*exec.ExitError); ok {
			return nil, fmt.Errorf("%w, stderr:\n%s", exitErr, exitErr.Stderr)
		}
		return nil, err
	}
	return currentSystem, nil
}

func GetInitEvalCmdArgs() (string, []string, error) {
	nix, err := GetNix()
	if err != nil {
		return "", nil, err
	}

	currentSystem, err := getCurrentSystem()
	if err != nil {
		return "", nil, err
	}
	return nix, append(
		flakeEvalJson, fmt.Sprintf(flakeInitFragment, ".", currentSystem)), nil
}

func GetActionEvalCmdArgs(c, o, t, a string) (string, []string, error) {
	nix, err := GetNix()
	if err != nil {
		return "", nil, err
	}

	currentSystem, err := getCurrentSystem()
	if err != nil {
		return "", nil, err
	}
	return nix, append(
		flakeBuild, fmt.Sprintf(flakeActionsFragment, ".", currentSystem, c, o, t, a)), nil
}

func LoadFlake() (*data.Root, error) {
	var root = &data.Root{}

	nix, args, err := GetInitEvalCmdArgs()
	if err != nil {
		return nil, err
	}

	// load the std metadata from the flake
	cmd := exec.Command(nix, args...)
	out, err := cmd.Output()
	if err != nil {
		if exitErr, ok := err.(*exec.ExitError); ok {
			return nil, fmt.Errorf("command: %s, %w, stderr:\n%s", cmd.String(), exitErr, exitErr.Stderr)
		}
		return nil, err
	}

	if err := json.Unmarshal(out, &root.Cells); err != nil {
		var obj interface{}
		json.Unmarshal(out, &obj)
		f := colorjson.NewFormatter()
		f.Indent = 2
		s, _ := f.Marshal(obj)
		return nil, fmt.Errorf("%w - object: %s", err, s)
	}

	// var obj interface{}
	// json.Unmarshal(out, &obj)
	// f := colorjson.NewFormatter()
	// f.Indent = 2
	// s, _ := f.Marshal(obj)
	// log.Fatalf("object: %s", s)

	return root, nil
}
