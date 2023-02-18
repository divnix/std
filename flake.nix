# SPDX-FileCopyrightText: 2022 The Standard Authors
# SPDX-FileCopyrightText: 2022 Kevin Amado <kamadorueda@gmail.com>
#
# SPDX-License-Identifier: Unlicense
{
  description = "The Nix Flakes framework for perfectionists with deadlines";
  # override downstream with inputs.std.inputs.nixpkgs.follows = ...
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  inputs.paisano.url = "github:divnix/paisano";
  inputs.paisano.inputs.nixpkgs.follows = "nixpkgs";
  inputs.paisano.inputs.yants.follows = "yants";
  inputs.yants.url = "github:divnix/yants";
  inputs.yants.inputs.nixpkgs.follows = "nixpkgs";
  inputs.dmerge.url = "github:divnix/data-merge";
  inputs.dmerge.inputs.nixlib.follows = "nixpkgs";
  inputs.dmerge.inputs.yants.follows = "yants";
  inputs.blank.url = "github:divnix/blank";
  inputs.incl.url = "github:divnix/incl";
  inputs.incl.inputs.nixlib.follows = "nixpkgs";
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
    devenv.follows = "blank";
  };
  outputs = inputs: let
    # this is a standard-specific contract to wrap the data block type with metadata
    dataWith = meta: data: {
      __std_data_wrapper = true;
      inherit data meta;
    };
    blockTypes = import ./src/blocktypes.nix {inherit (inputs) nixpkgs;};
    sharedActions = import ./src/actions.nix {inherit (inputs) nixpkgs;};
    l = inputs.nixpkgs.lib // builtins;

    growOn = {
      cellBlocks ? [
        (blockTypes.functions "library")
        (blockTypes.runnables "apps")
        (blockTypes.installables "packages")
      ],
      ...
    } @ args:
      inputs.paisano.growOn (args // {inherit cellBlocks;}) {
        # standard-specific quality-of-life assets
        __std.direnv_lib = ./direnv_lib.sh;
        __std.nixConfig = let
          # FIXME: refactor when merged NixOS/nixpkgs#203999
          nixConfig = l.generators.toKeyValue {
            mkKeyValue = l.generators.mkKeyValueDefault {
              mkValueString = v:
                if l.isList v
                then l.concatStringsSep " " v
                else if (l.isPath v || v ? __toString)
                then toString v
                else l.generators.mkValueStringDefault {} v;
            } " = ";
          };
        in
          nixConfig (import "${args.inputs.self}/flake.nix").nixConfig or {};
      };
    grow = args: l.removeAttrs (growOn args) ["__functor"];
    flakeModule = import ./src/flakeModule.nix {
      inherit grow;
      inherit (inputs.paisano) harvest pick winnow;
      types = import (inputs.paisano + /types/defauls.nix) {
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
