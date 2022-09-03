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
  local block="${frgmnts[0]}"
  local organ="${frgmnts[1]}"
  local target="${frgmnts[2]}"
  local profile_path="$direnv_layout_dir/$block/$organ/$target"

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

  shift 2
  if [[ $# -gt 0 ]]; then
    nix_args+=("${@}")
  fi

  if [[ -f "$cellsroot/$block/$organ/$target.nix" ]]; then
    log_status "Watching: $block/$organ/$target.nix"
    watch_file "$cellsroot/$block/$organ/$target.nix"
  elif [[ -f "$cellsroot/$block/$organ/default.nix" ]]; then
    log_status "Watching: $block/$organ/default.nix"
    watch_file "$cellsroot/$block/$organ.nix"
  elif [[ -f "$cellsroot/$block/$organ.nix" ]]; then
    log_status "Watching: $cellsroot/$block/$organ.nix"
    watch_file "$cellsroot/$block/$organ.nix"
  fi

  if [[ -d "$cellsroot/$block/$organ/$target" ]]; then
    log_status "Watching: $cellsroot/$block/$organ/$target (recursively)"
    watch_dir "$cellsroot/$block/$organ/$target"
  elif [[ -d "$cellsroot/$block/$organ" ]]; then
    log_status "Watching: $cellsroot/$block/$organ (recursively)"
    watch_dir "$cellsroot/$block/$organ"
  fi

  mkdir -p "$(direnv_layout_dir)/$block/$organ/$target"

  nix build "$PWD#$system.$block.$organ.$target" "${nix_args[@]}" --profile "$profile_path/shell-profile"
  . "$profile_path/shell-profile/entrypoint"
  # this is not true
  unset IN_NIX_SHELL
}
