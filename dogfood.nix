{
  grow,
  inputs,
  clades,
}:
grow {
  inherit inputs;
  cellsFrom = ./cells;
  organelles = [
    (clades.runnables "cli")
    (clades.functions "lib")
    (clades.functions "devshellProfiles")
    (clades.devshells "devshells")
    (clades.data "data")
  ];
}
