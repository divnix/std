#! /bin/sh

_url='https://raw.githubusercontent.com/paisano-nix/direnv/096f54a7a63285293d87737ae195bd8f51663668/lib'
_hash='sha256-XKqDMz+VtF8VSJ4yOok4mO1xxXUZbD1t2yC0JmEXrCI='

source "$(fetchurl "$_url" "$_hash")"

echo -e "\033[1m\033[31m------------------------------------------------------------------\e[0m"
echo -e "\033[1m\033[31mUse of '.#__std.direnv_lib' is deprecated and will be removed soon\033[0m"
echo -e "\033[1m\033[32mPlease adopt \033[33mhttps://github.com/paisano-nix/direnv\033[32m for your .envrc\033[0m"
echo -e "\033[1m\033[32m------------------------------------------------------------------\e[0m"

use_std () {
  local _not_used="$1"
  local target="$2"
  use envreload "${target//:/\/}"
}
