package main

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"os"
	"os/exec"

	"math/rand"
	"time"

	"github.com/TylerBrock/colorjson"
	tea "github.com/charmbracelet/bubbletea"

	"github.com/divnix/std/data"
	"github.com/divnix/std/dummy_data"
)

type outt struct {
	drvPath string            `json:"drvPath"`
	outputs map[string]string `json:"outputs"`
}

var (
	currentSystemArgs    = []string{"eval", "--raw", "--impure", "--expr", "builtins.currentSystem"}
	flakeStdMetaFragment = "%s#__std.%s"
	flakeStdMetaArgs     = []string{"build", "--no-link", "--json", "--option", "warn-dirty", "false"}
	flakeStdBuildOut     = []map[string]interface{}{}
)

func fakeData() []data.Item {
	rand.Seed(time.Now().UTC().UnixNano())
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
		return fatalErrf("You need to install 'nix' in order to use 'std'")
	}

	// detect the current system
	currentSystem, err := exec.Command(nix, currentSystemArgs...).Output()
	if err != nil {
		if exitErr, ok := err.(*exec.ExitError); ok {
			return fatalErrf("%w, stderr:\n%s", exitErr, exitErr.Stderr)
		}
		return fatalErr(err)
	}

	flakeStdMetaFragment = fmt.Sprintf(flakeStdMetaFragment, ".", currentSystem)
	flakeStdMetaArgs = append(flakeStdMetaArgs, flakeStdMetaFragment)

	// load the std metadata from the flake
	cmd := exec.Command(nix, flakeStdMetaArgs...)
	out, err := cmd.Output()
	if err != nil {
		if exitErr, ok := err.(*exec.ExitError); ok {
			return fatalErrf("command: %s, %w, stderr:\n%s", cmd.String(), exitErr, exitErr.Stderr)
		}
		return fatalErr(err)
	}

	if err := json.Unmarshal(out, &flakeStdBuildOut); err != nil {
		return fatalErr(err)
	}

	flakeStdMetaJson, err := os.Open(flakeStdBuildOut[0]["outputs"].(map[string]interface{})["out"].(string))
	if err != nil {
		return fatalErr(err)
	}
	// if we os.Open returns an error then handle it
	defer flakeStdMetaJson.Close()

	// read our opened jsonFile as a byte array.
	flakeStdMeta, _ := ioutil.ReadAll(flakeStdMetaJson)

	if err := json.Unmarshal(flakeStdMeta, &items); err != nil {
		var obj interface{}
		json.Unmarshal(flakeStdMeta, &obj)
		f := colorjson.NewFormatter()
		f.Indent = 2
		s, _ := f.Marshal(obj)
		return fatalErrf("%w - object: %s", err, s)
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

type fatalErrMsg struct {
	err error
}

func fatalErr(err error) fatalErrMsg {
	return fatalErrMsg{err}
}

func fatalErrf(f string, a ...interface{}) fatalErrMsg {
	return fatalErrMsg{fmt.Errorf(f, a...)}
}
