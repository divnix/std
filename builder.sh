# SPDX-FileCopyrightText: 2022 David Arnold <dgx.arnold@gmail.com>
# SPDX-FileCopyrightText: 2022 Kevin Amado <kamadorueda@gmail.com>
#
# SPDX-License-Identifier: Unlicense

source $stdenv/setup
source $someVarSetup2

# set -x
# echo "${someVarSetup}"
# eval "declare -A someVar=$someVarSetup"
# set +x

for key in "${!someVar[@]}"; do
  val="${someVar[$key]}"
  echo $key: $val
done
