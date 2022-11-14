#! /usr/bin/env bash
exec nix run nixpkgs#caddy -- file-server --browse "$@"
