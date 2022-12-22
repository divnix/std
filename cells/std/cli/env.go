package main

import (
	"bytes"
	"fmt"
	"os"
	"os/exec"
	"strings"
)

// PRJ_ROOT is a useful environment contract prototyped by `numtide/devshell`
// TODO: coordinate with `numtide` about PRJ Base Directory Specification
const (
	PRJ_ROOT          = "PRJ_ROOT"
	PRJ_DATA_DIR      = "PRJ_DATA_DIR"
	PRJ_CACHE_DIR     = "PRJ_CACHE_DIR"
	NIX_CONFIG        = "NIX_CONFIG"
	prjRootGitCmd     = "git rev-parse --show-toplevel"
	prjDataDirTmpl    = "%s/.std"
	prjCacheDirTmpl   = "%s/.std/cache"
	prjLastActionTmpl = "%s/.std/last-action"
)

func setEnv() (string, string, string, string, error) {
	var prjRoot string
	prjRoot, present := os.LookupEnv(PRJ_ROOT)
	if !present {
		args := strings.Fields(prjRootGitCmd)
		prjRootB, err := exec.Command(args[0], args[1:]...).Output()
		prjRootB = bytes.TrimRight(prjRootB, "\n")
		prjRoot = string(prjRootB[:])
		if err != nil {
			if exitErr, ok := err.(*exec.ExitError); ok {
				return "", "", "", "", fmt.Errorf("%w, stderr:\n%s", exitErr, exitErr.Stderr)
			}
			return "", "", "", "", err
		}

		os.Setenv(PRJ_ROOT, prjRoot)
	}
	prjDataDir, present := os.LookupEnv(PRJ_DATA_DIR)
	if !present {
		prjDataDir = fmt.Sprintf(prjDataDirTmpl, prjRoot)
		os.Setenv(PRJ_DATA_DIR, prjDataDir)
	}
	prjCacheDir, present := os.LookupEnv(PRJ_CACHE_DIR)
	if !present {
		prjCacheDir = fmt.Sprintf(prjCacheDirTmpl, prjRoot)
		os.Setenv(PRJ_CACHE_DIR, prjCacheDir)
	}
	nixConfigEnv, present := os.LookupEnv(NIX_CONFIG)
	if !present {
		os.Setenv(NIX_CONFIG, extraNixConfig)
	} else {
		os.Setenv(NIX_CONFIG, fmt.Sprintf("%s\n%s", nixConfigEnv, extraNixConfig))
	}
	return prjRoot, prjDataDir, prjCacheDir, fmt.Sprintf(prjLastActionTmpl, prjRoot), nil
}
