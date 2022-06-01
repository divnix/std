#!/usr/bin/env bash

# SPDX-FileCopyrightText: 2022 The Standard Authors
# SPDX-License-Identifier: Unlicense

# re-branding & force congruent choice with `std` CLI
direnv_layout_dir=$PWD/.std

# Usage use std <cellsroot> <target>
#
# Loads the environment determined by the given std target
#
# Example (.envrc):
#   source_url https://raw.githubusercontent.com/divnix/std/main/direnv_lib.sh <integrity-hash>
#   use std cells //std/devshells:default
#
# Find out the integrity hash:
#   direnv fetchurl https://raw.githubusercontent.com/divnix/std/main/direnv_lib.sh
use_std() {
  local system="$(nix eval --raw --impure --expr builtins.currentSystem)"
  local cellsroot="$1"
  local frgmnts=($(echo "$2" | sed 's#//##' | sed 's#:# #' | sed 's#/# #g'))
  local clade="${frgmnts[0]}"
  local organ="${frgmnts[1]}"
  local targt="${frgmnts[2]}"
  local profile_path="$(direnv_layout_dir)/$clade/$organ/$targt"

  local nix_args=(
    "$PWD#$system.$clade.$organ.$targt"
    "--no-update-lock-file"
    "--no-write-lock-file"
    "--no-warn-dirty"
    "--accept-flake-config"
    "--keep-outputs"
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

  if [[ -d "$cellsroot/$clade/$organ/$targt" ]]; then
    log_status "Watching: $cellsroot/$clade/$organ/$targt (recursively)"
    watch_dir "$cellsroot/$clade/$organ/$targt"
  elif [[ -d "$cellsroot/$clade/$organ" ]]; then
    log_status "Watching: $cellsroot/$clade/$organ (recursively)"
    watch_dir "$cellsroot/$clade/$organ"
  fi

  mkdir -p "$(direnv_layout_dir)/$clade/$organ/$targt"

  nix build "${nix_args[@]}" --profile "$profile_path/shell-profile"
  eval "$(nix print-dev-env ${nix_args[@]} --profile $profile_path/env-profile)"
  # this is not true
  unset IN_NIX_SHELL
}
