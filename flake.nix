# SPDX-FileCopyrightText: 2022 The Standard Authors
# SPDX-FileCopyrightText: 2022 Kevin Amado <kamadorueda@gmail.com>
#
# SPDX-License-Identifier: Unlicense
{
  description = "The Nix Flakes framework for perfectionists with deadlines";
  # override downstream with inputs.std.inputs.nixpkgs.follows = ...
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  inputs.yants.url = "github:divnix/yants";
  inputs.yants.inputs.nixpkgs.follows = "nixpkgs";
  outputs = inputs: let
    l = inputs.nixpkgs.lib // builtins;
    clades = import ./src/clades.nix {inherit (inputs) nixpkgs;};
    incl = import ./src/incl.nix {inherit (inputs) nixpkgs;};
    deSystemize = import ./src/de-systemize.nix;
    grow = import ./src/grow.nix {inherit (inputs) nixpkgs yants;};

    growOn = args: soil:
      l.attrsets.recursiveUpdate (
        soil
        // {
          __functor = self: soil':
            growOn args (l.recursiveUpdate soil' self);
        }
      ) (grow args);
  in
    {
      inherit (clades) runnables installables functions data;
      inherit grow growOn deSystemize incl;
      systems = l.systems.doubles;
    }
    # on our own account ...
    // (
      grow {
        inherit inputs;
        cellsFrom = ./cells;
        organelles = [
          (clades.runnables "cli")
          (clades.functions "lib")
          (clades.functions "devshellProfiles")
          (clades.data "data")
        ];
        systems = ["x86_64-linux" "x86_64-darwin" "aarch64-darwin"];
      }
    );
}
