{
  description = "A very basic flake";

  inputs.std.url = "github:divnix/std";
  inputs.std.inputs.nixpkgs.follows = "nixpkgs";

  inputs.fenix.url = "github:nix-community/fenix";
  inputs.crane.url = "github:ipetkov/crane";
  inputs.crane.inputs.nixpkgs.follows = "nixpkgs";
  inputs.crane.inputs.flake-utils.follows = "std/flake-utils";

  inputs.nixpkgs.follows = "fenix/nixpkgs";

  outputs = inputs @ {
    self,
    std,
    ...
  }:
    std.growOn {
      inherit inputs;
      systems = ["x86_64-linux"];
      cellsFrom = ./nix;
      cellBlocks = [
        (std.devshells "devshells")
        (std.installables "packages")
      ];
    } {
      devShells = std.harvest self ["_automation" "devshells"];
      packages = std.harvest self ["hello" "packages"];
    };

  nixConfig = {
    extra-substituters = [
      "https://nix-community.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };
}
