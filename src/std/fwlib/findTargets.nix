{nixpkgs}: {
  inputs,
  cell,
  block,
}: let
  inherit (nixpkgs.lib) mapAttrs' nameValuePair removeSuffix toFunction;
  inherit (builtins) readDir removeAttrs mapAttrs;

  load = file: toFunction (scopedImport {inherit inputs cell;} file) {inherit inputs cell;};
  targets = removeAttrs (readDir block) ["default.nix"];
in
  mapAttrs' (
    name: _:
      nameValuePair (removeSuffix ".nix" name) (load (block + /${name}))
  )
  targets
