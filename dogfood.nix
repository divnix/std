{
  growOn,
  inputs,
  clades,
  harvest,
}:
growOn {
  inherit inputs;
  cellsFrom = ./cells;
  organelles = [
    (clades.runnables "cli")
    (clades.functions "lib")
    (clades.functions "devshellProfiles")
    (clades.devshells "devshells")
    (clades.data "data")
    (clades.files "files")
  ];
} {
  devShells = harvest inputs.self ["std" "devshells"];
  packages = harvest inputs.self ["std" "cli"];
}
