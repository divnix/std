# SPDX-FileCopyrightText: 2022 David Arnold <dgx.arnold@gmail.com>
# SPDX-FileCopyrightText: 2022 Kevin Amado <kamadorueda@gmail.com>
#
# SPDX-License-Identifier: Unlicense

# shellcheck shell=bash

source "${stdenv}/setup"

function replace_arg_in_file {
  local file="${1}"
  local arg_name="${2}"
  local arg_value="${3}"

  if grep --fixed-strings --quiet "${arg_name}" "${file}"; then
    rpl --quiet -- "${arg_name}" "${arg_value}" "${file}" 2>/dev/null
  else
    echo: "${arg_name}", please remove it
  fi
}

function installPhase {
  out="${out}${destination}"
  mkdir -p "$(dirname "${out}")"

  set -x
  substitute "${src}" "${out}" ${envSubstituteArgs}
  set +x

  if test -n "${envExecutable}"; then
    chmod +x "${out}"
  fi
}

dontUnpack=1
genericBuild
