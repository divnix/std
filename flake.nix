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
  /*
   Auxiliar inputs used in builtin libraries or for the dev environment.
   */
  inputs = {
    devshell.url = "github:numtide/devshell";
    devshell.inputs.nixpkgs.follows = "nixpkgs";
  };
  outputs = inputs: let
    clades = import ./src/clades.nix {inherit (inputs) nixpkgs;};
    incl = import ./src/incl.nix {inherit (inputs) nixpkgs;};
    deSystemize = import ./src/de-systemize.nix;
    grow = import ./src/grow.nix {inherit (inputs) nixpkgs yants;};
    growOn = import ./src/grow-on.nix {inherit (inputs) nixpkgs yants;};
    harvest = import ./src/harvest.nix {inherit (inputs) nixpkgs;};
    l = inputs.nixpkgs.lib // builtins;
  in
    {
      inherit (clades) runnables installables functions data devshells;
      inherit grow growOn deSystemize incl harvest;
      systems = l.systems.doubles;
    }
    # on our own account ...
    // (import ./dogfood.nix {inherit inputs grow clades;});
}
