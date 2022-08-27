#!/usr/bin/env bash

# SPDX-FileCopyrightText: 2022 The Standard Authors
# SPDX-License-Identifier: Unlicense

# re-branding & force congruent choice with `std` CLI
direnv_layout_dir=$(git rev-parse --show-toplevel)/.std

# nicer dienv & nixago output styling
export DIRENV_LOG_FORMAT=$'\E[mdirenv: \E[38;5;8m%s\E[m'

# Usage use std <cellsroot> <target>
#
# Loads the environment determined by the given std target
#
# Example (.envrc):
#   source "$(nix eval .#__std.direnv_lib)"
#   use std cells //std/devshells:default
use_std() {
  local system
  system="$(nix eval --raw --impure --expr builtins.currentSystem)"
  local cellsroot="$1"
  local frgmnts=($(echo "$2" | sed 's#//##' | sed 's#:# #' | sed 's#/# #g'))
  local clade="${frgmnts[0]}"
  local organ="${frgmnts[1]}"
  local target="${frgmnts[2]}"
  local profile_path="$direnv_layout_dir/$clade/$organ/$target"

  local nix_args=(
    "--no-update-lock-file"
    "--no-write-lock-file"
    "--no-warn-dirty"
    "--no-link"
    "--keep-outputs"
    "--build-poll-interval" "0"
    "--accept-flake-config"
    "--builders-use-substitutes"
  )

  if [[ -f "$cellsroot/$clade/$organ/$target.nix" ]]; then
    log_status "Watching: $clade/$organ/$target.nix"
    watch_file "$cellsroot/$clade/$organ/$target.nix"
  elif [[ -f "$cellsroot/$clade/$organ/default.nix" ]]; then
    log_status "Watching: $clade/$organ/default.nix"
    watch_file "$cellsroot/$clade/$organ.nix"
  elif [[ -f "$cellsroot/$clade/$organ.nix" ]]; then
    log_status "Watching: $cellsroot/$clade/$organ.nix"
    watch_file "$cellsroot/$clade/$organ.nix"
  fi

  if [[ -d "$cellsroot/$clade/$organ/$target" ]]; then
    log_status "Watching: $cellsroot/$clade/$organ/$target (recursively)"
    watch_dir "$cellsroot/$clade/$organ/$target"
  elif [[ -d "$cellsroot/$clade/$organ" ]]; then
    log_status "Watching: $cellsroot/$clade/$organ (recursively)"
    watch_dir "$cellsroot/$clade/$organ"
  fi

  mkdir -p "$(direnv_layout_dir)/$clade/$organ/$target"

  nix build "$PWD#$system.$clade.$organ.$target" "${nix_args[@]}" --profile "$profile_path/shell-profile"
  . "$profile_path/shell-profile/entrypoint"
  # this is not true
  unset IN_NIX_SHELL
}
