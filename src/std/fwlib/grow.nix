{root}: let
  inherit (root) growOn;
in
  args: removeAttrs (growOn args) ["__functor"]
