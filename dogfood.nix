{
  growOn,
  inputs,
  blockTypes,
  harvest,
}:
growOn {
  inherit inputs;
  cellsFrom = ./cells;
  cellBlocks = [
    (blockTypes.runnables "cli")
    (blockTypes.functions "lib")
    (blockTypes.functions "devshellProfiles")
    (blockTypes.devshells "devshells")
    (blockTypes.installables "packages")
    (blockTypes.nixago "nixago")
    (blockTypes.data "data")
    (blockTypes.files "files")
    (blockTypes.data "templates")
  ];
} {
  devShells = harvest inputs.self ["automation" "devshells"];
  packages = harvest inputs.self [["std" "cli"] ["std" "packages"]];
  templates = let
    r = harvest inputs.self ["presets" "templates"];
    r' = builtins.head (builtins.attrNames r);
  in
    r.${r'};
}
