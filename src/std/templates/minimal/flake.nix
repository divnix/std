{
  description = "CONFIGURE-ME";

  inputs.std.url = "github:divnix/std";
  inputs.nixpkgs.follows = "std/nixpkgs";
  inputs.std.inputs.devshell.url = "github:numtide/devshell";
  inputs.std.inputs.nixago.url = "github:nix-community/nixago";

  outputs = { std, ... } @ inputs:
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
