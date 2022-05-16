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
    kroki-preprocessor.url = "github:input-output-hk/mdbook-kroki-preprocessor";
  };
  outputs = inputs: let
    l = inputs.nixpkgs.lib // builtins;
    clades = import ./src/clades.nix {inherit (inputs) nixpkgs;};
    incl = import ./src/incl.nix {inherit (inputs) nixpkgs;};
    deSystemize = import ./src/de-systemize.nix;
    grow = import ./src/grow.nix {inherit (inputs) nixpkgs yants;};

    growOn = args:
      grow args
      // {
        __functor = l.flip l.recursiveUpdate;
      };
    harvest = t: p:
      l.mapAttrs (_: v: l.getAttrFromPath p v)
      (
        l.filterAttrs (
          n: v:
            (l.elem n l.systems.doubles.all) # avoids infinit recursion
            && (l.hasAttrByPath p v)
        )
        t
      );
  in
    {
      inherit (clades) runnables installables functions data devshells;
      inherit grow growOn deSystemize incl harvest;
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
          (clades.devshells "devshells")
          (clades.data "data")
        ];
        systems = [
          "aarch64-darwin"
          "aarch64-linux"
          "x86_64-darwin"
          "x86_64-linux"
        ];
      }
    );
}
