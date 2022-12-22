package main

import (
	"bytes"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"os"
	"os/exec"
	"strings"

	"github.com/TylerBrock/colorjson"

	"github.com/divnix/std/cache"
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
	flakeEvalJson        = []string{
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
	_, _, _, actionPath, err := setEnv()
	if err != nil {
		return "", nil, err
	}
	return nix, append(
		flakeBuild(actionPath), fmt.Sprintf(flakeActionsFragment, ".", currentSystem, c, o, t, a)), nil
}

func LoadJson(r io.Reader) (*data.Root, error) {
	var root = &data.Root{}

	var r2 bytes.Buffer
	r1 := io.TeeReader(r, &r2)

	var dec = json.NewDecoder(r1)

	if err := dec.Decode(&root.Cells); err != nil {
		var serr *json.SyntaxError
		if errors.As(err, &serr) {
			return nil, fmt.Errorf("json syntax error: %w: string:\n%v", err, r2.String())
		}
		var obj interface{}
		var debugDecoder = json.NewDecoder(&r2)
		debugDecoder.Decode(&obj)
		f := colorjson.NewFormatter()
		f.Indent = 2
		s, _ := f.Marshal(obj)
		return nil, fmt.Errorf("%w - object: %s", err, s)
	}

	return root, nil
}

func LoadFlakeCmd() (*cache.Cache, *cache.ActionID, *exec.Cmd, *bytes.Buffer, error) {

	nix, args, err := GetInitEvalCmdArgs()
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
	_, _, prjCacheDir, _, err := setEnv()
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
