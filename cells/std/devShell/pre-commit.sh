#!/usr/bin/env bash

# SPDX-FileCopyrightText: 2022 David Arnold <dgx.arnold@gmail.com>
# SPDX-FileCopyrightText: 2022 Kevin Amado <kamadorueda@gmail.com>
#
# SPDX-License-Identifier: Unlicense

if git rev-parse --verify HEAD >/dev/null 2>&1; then
  against=HEAD
else
  # Initial commit: diff against an empty tree object
  against=$(${git}/bin/git hash-object -t tree /dev/null)
fi

diff="git diff-index --name-only --cached $against --diff-filter d"
all_files=($($diff))

# Format the entire tree.
treefmt

# check editorconfig
editorconfig-checker -- "${all_files[@]}"
if [[ $? != '0' ]]; then
  printf "%b\n" \
    "\nCode is not aligned with .editorconfig" \
    "Review the output and commit your fixes" >&2
  exit 1
fi
