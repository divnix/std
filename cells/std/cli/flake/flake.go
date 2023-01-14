package flake

import (
	"bytes"
	"errors"
	"fmt"
	"os"
	"os/exec"
	"strings"

	"github.com/divnix/std/cache"
	"github.com/divnix/std/env"
)

type outt struct {
	drvPath string            `json:"drvPath"`
	outputs map[string]string `json:"outputs"`
}

var (
	currentSystemArgs      = []string{"eval", "--raw", "--impure", "--expr", "builtins.currentSystem"}
	cellsFromArgs          = []string{"eval", "--raw"}
	flakeCellsFromFragment = "%s#__std.cellsFrom"
	flakeInitFragment      = "%s#__std.init"
	flakeActionsFragment   = "%s#__std.actions.%s.%s.%s.%s.%s"
	flakeEvalJson          = []string{
		"eval",
		"--json",
		"--no-update-lock-file",
		"--no-write-lock-file",
		"--no-warn-dirty",
		"--accept-flake-config",
	}
	flakeBuild = func(out string) []string {
		return []string{
			"build",
			"--out-link", out,
			"--no-update-lock-file",
			"--no-write-lock-file",
			"--no-warn-dirty",
			"--accept-flake-config",
			"--builders-use-substitutes",
		}
	}
)

func getNix() (string, error) {
	nix, err := exec.LookPath("nix")
	if err != nil {
		return "", errors.New("You need to install 'nix' in order to use 'std'")
	}
	return nix, nil
}

func getCurrentSystem() ([]byte, error) {
	// detect the current system
	nix, err := getNix()
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

func GetCellsFrom() (string, error) {
	nix, err := getNix()
	if err != nil {
		return "", err
	}
	cellsFrom, err := exec.Command(nix, append(cellsFromArgs, fmt.Sprintf(flakeCellsFromFragment, "."))...).Output()
	if err != nil {
		if exitErr, ok := err.(*exec.ExitError); ok {
			return "", fmt.Errorf("%w, stderr:\n%s", exitErr, exitErr.Stderr)
		}
		return "", err
	}
	return string(cellsFrom[:]), nil
}

func getInitEvalCmdArgs() (string, []string, error) {
	nix, err := getNix()
	if err != nil {
		return "", nil, err
	}

	return nix, append(
		flakeEvalJson, fmt.Sprintf(flakeInitFragment, ".")), nil
}

func GetActionEvalCmdArgs(c, o, t, a string) (string, []string, error) {
	nix, err := getNix()
	if err != nil {
		return "", nil, err
	}

	currentSystem, err := getCurrentSystem()
	if err != nil {
		return "", nil, err
	}
	_, _, _, actionPath, err := env.SetEnv()
	if err != nil {
		return "", nil, err
	}
	return nix, append(
		flakeBuild(actionPath), fmt.Sprintf(flakeActionsFragment, ".", currentSystem, c, o, t, a)), nil
}

func LoadFlakeCmd() (*cache.Cache, *cache.ActionID, *exec.Cmd, *bytes.Buffer, error) {

	nix, args, err := getInitEvalCmdArgs()
	if err != nil {
		return nil, nil, nil, nil, err
	}
	devNull, err := os.Open(os.DevNull)
	if err != nil {
		return nil, nil, nil, nil, err
	}

	// load the std metadata from the flake
	buf := new(bytes.Buffer)
	cmd := exec.Command(nix, args...)
	cmd.Stdin = devNull
	cmd.Stdout = buf

	// initialize cache
	_, _, prjCacheDir, _, err := env.SetEnv()
	if err != nil {
		return nil, nil, nil, nil, err
	}
	path := prjCacheDir
	err = os.MkdirAll(path, os.ModePerm)
	if err != nil {
		return nil, nil, nil, nil, err
	}
	c, err := cache.Open(path)
	if err != nil {
		return nil, nil, nil, nil, err
	}
	key := cache.NewActionID([]byte(strings.Join(args, "")))

	return c, &key, cmd, buf, nil
}
