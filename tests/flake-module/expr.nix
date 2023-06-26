{
  inputs,
  std,
  flake-parts,
}: (flake-parts.lib.mkFlake {inherit inputs;} {
  systems = ["aarch64-darwin" "aarch64-linux" "x86_64-darwin" "x86_64-linux"];
  std.grow.cellsFrom = ./__fixture;
  std.grow.cellBlocks = with std.blockTypes; [
    (devshells "shells")
  ];
  std.harvest = {
    devShells = [
      ["local" "shells"]
    ];
  };
  imports = [
    std.flakeModule
  ];
})
