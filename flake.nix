# SPDX-FileCopyrightText: 2022 The Standard Authors
# SPDX-FileCopyrightText: 2022 Kevin Amado <kamadorueda@gmail.com>
#
# SPDX-License-Identifier: Unlicense
{
  description = "The Nix Flakes framework for perfectionists with deadlines";
  # override downstream with inputs.std.inputs.nixpkgs.follows = ...
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  inputs = {
    paisano.url = "github:paisano-nix/core/0.1.0";
    paisano.inputs.nixpkgs.follows = "nixpkgs";
    paisano.inputs.yants.follows = "yants";
    paisano-tui.url = "github:paisano-nix/tui/0.1.1";
    paisano-tui.inputs.std.follows = "/";
    paisano-tui.inputs.nixpkgs.follows = "blank";
    paisano-mdbook-preprocessor.url = "github:paisano-nix/mdbook-paisano-preprocessor";
    paisano-mdbook-preprocessor.inputs.std.follows = "/";
    paisano-mdbook-preprocessor.inputs.nixpkgs.follows = "nixpkgs";
  };
  inputs.blank.url = "github:divnix/blank";
  inputs.yants = {
    url = "github:divnix/yants";
    inputs.nixpkgs.follows = "nixpkgs";
  };
  inputs.dmerge = {
    url = "github:divnix/dmerge/0.2.0";
    inputs.nixlib.follows = "nixpkgs";
    inputs.yants.follows = "yants";
  };
  inputs.incl = {
    url = "github:divnix/incl";
    inputs.nixlib.follows = "nixpkgs";
  };
  /*
  Auxiliar inputs used in builtin libraries or for the dev environment.
  */
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    devshell.url = "github:numtide/devshell";
    devshell.inputs.nixpkgs.follows = "nixpkgs";
    devshell.inputs.flake-utils.follows = "flake-utils";
    nixago.url = "github:nix-community/nixago";
    nixago.inputs.nixpkgs.follows = "nixpkgs";
    nixago.inputs.nixago-exts.follows = "blank";
    nixago.inputs.flake-utils.follows = "flake-utils";
    n2c.url = "github:nlewo/nix2container";
    n2c.inputs.nixpkgs.follows = "nixpkgs";
    n2c.inputs.flake-utils.follows = "flake-utils";

    # Placeholder inputs that can be overloaded via follows
    microvm.follows = "blank";
    makes.follows = "blank";
    arion.follows = "blank";
  };
  outputs = inputs: let
    # this is a standard-specific contract to wrap the data block type with metadata
    dataWith = meta: data: {
      __std_data_wrapper = true;
      inherit data meta;
    };
    blockTypes = import ./src/blocktypes.nix {inherit (inputs) nixpkgs n2c;};
    sharedActions = import ./src/actions.nix {inherit (inputs) nixpkgs;};
    l = inputs.nixpkgs.lib // builtins;

    growOn = {
      cellBlocks ? [
        (blockTypes.functions "library")
        (blockTypes.runnables "apps")
        (blockTypes.installables "packages")
      ],
      ...
    } @ args: let
      # preserve pos of `cellBlocks` if not using the default
      args' =
        args
        // (
          if args ? cellBlocks
          then {}
          else {inherit cellBlocks;}
        );
    in
      inputs.paisano.growOn args' {
        # standard-specific quality-of-life assets
        __std.direnv_lib = ./direnv_lib.sh;
      };
    grow = args: l.removeAttrs (growOn args) ["__functor"];
    flakeModule = import ./src/flakeModule.nix {
      inherit grow;
      inherit (inputs.paisano) harvest pick winnow;
      types = import (inputs.paisano + /types/default.nix) {
        inherit l;
        inherit (inputs) yants;
        paths = null;
      };
    };
  in
    {
      inherit (inputs) yants dmerge incl; # convenience re-exports
      inherit blockTypes sharedActions dataWith;
      inherit (blockTypes) runnables installables functions data devshells containers files microvms nixago nomadJobManifests;
      inherit grow growOn;
      inherit (inputs.paisano) pick harvest winnow;
      systems = l.systems.doubles;
      inherit flakeModule;
    }
    # on our own account ...
    // (import ./dogfood.nix {
      inherit inputs blockTypes growOn;
      inherit (inputs.paisano) pick harvest;
    });
}
