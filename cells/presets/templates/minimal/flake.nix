{
  description = "CONFIGURE-ME";

  inputs.std.url = "github:divnix/std";
  inputs.nixpkgs.follows = "std/nixpkgs";

  outputs = {std, ...} @ inputs:
    std.growOn {
      inherit inputs;
      cellsFrom = ./nix;
      cellBlocks = with std.blockTypes; [
        # Development Environments
        (nixago "configs")
        (devshells "shells")
      ];
    };
}
