{
  inputs,
  cell,
}: let
  inherit (inputs) cells;
  inherit (inputs.std) findTargets;

  inherit (inputs.nixpkgs.lib) recursiveUpdate mapAttrs;

  data = findTargets {
    inherit inputs cell;
    block = ./.;
  };
in
  mapAttrs (name: config: recursiveUpdate config (data.${name} or {})) cells.lib.cfg
