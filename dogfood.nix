{
  growOn,
  inputs,
  clades,
  harvest,
}:
growOn {
  inherit inputs;
  cellsFrom = ./cells;
  cellBlocks = [
    (clades.runnables "cli")
    (clades.functions "lib")
    (clades.functions "devshellProfiles")
    (clades.devshells "devshells")
    (clades.installables "packages")
    (clades.nixago "nixago")
    (clades.data "data")
    (clades.files "files")
  ];
} {
  devShells = harvest inputs.self ["automation" "devshells"];
  packages = harvest inputs.self [["std" "cli"] ["std" "packages"]];
}
