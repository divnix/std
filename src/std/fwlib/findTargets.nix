{nixpkgs}: {
  inputs,
  cell,
  block,
}: let
  inherit (nixpkgs.lib) mapAttrs' nameValuePair removeSuffix filterAttrs hasSuffix;
  inherit (builtins) readDir removeAttrs mapAttrs;

  load = file: scopedImport {inherit inputs cell;} file;
  targets = filterAttrs (n: _: hasSuffix ".nix" n) (removeAttrs (readDir block) ["default.nix"]);
in
  mapAttrs' (
    name: _:
      nameValuePair (removeSuffix ".nix" name) (load (block + /${name}))
  )
  targets
