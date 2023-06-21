# SPDX-FileCopyrightText: 2022 The Standard Authors
# SPDX-FileCopyrightText: 2022 Kevin Amado <kamadorueda@gmail.com>
#
# SPDX-License-Identifier: Unlicense
{
  description = "The Nix Flakes framework for perfectionists with deadlines";
  # override downstream with inputs.std.inputs.nixpkgs.follows = ...
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  inputs = {
    paisano.url = "github:paisano-nix/core";
    paisano.inputs.nixpkgs.follows = "nixpkgs";
    paisano.inputs.yants.follows = "yants";
    paisano-tui = {
        url = "github:paisano-nix/tui/0.1.1";
        flake = false; # we're after the source code, only
    };
  };
  inputs.blank.url = "github:divnix/blank";
  inputs.yants = {
    url = "github:divnix/yants";
    inputs.nixpkgs.follows = "haumea/nixpkgs";
  };
  inputs.dmerge = {
    url = "github:divnix/dmerge/0.2.1";
    inputs.haumea.follows = "haumea";
    inputs.yants.follows = "yants";
    inputs.nixlib.follows = "haumea/nixpkgs";
  };
  inputs.haumea = {
    url = "github:nix-community/haumea/v0.2.2";
  };
  inputs.incl = {
    url = "github:divnix/incl";
    inputs.nixlib.follows = "haumea/nixpkgs";
  };
  /*
  Auxiliar inputs used in builtin libraries or for the dev environment.
  */
  inputs = {
    # Placeholder inputs that can be overloaded via follows
    n2c.follows = "blank";
    devshell.follows = "blank";
    nixago.follows = "blank";
    microvm.follows = "blank";
    makes.follows = "blank";
    arion.follows = "blank";
  };
  outputs = {
    nixpkgs,
    haumea,
    paisano,
    ...
  } @ inputs: let
    lib = haumea.lib.load {
      src = ./lib;
      inputs = (removeAttrs inputs ["self"]) // {inherit grow;};
    };

    growOn = {
      cellBlocks ? [
        (lib.blockTypes.functions "library")
        (lib.blockTypes.runnables "apps")
        (lib.blockTypes.installables "packages")
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
      paisano.growOn args' {
        # standard-specific quality-of-life assets
        __std.direnv_lib = ./direnv_lib.sh;
      };
    grow = args: removeAttrs (growOn args) ["__functor"];
  in
    {
      inherit (inputs) yants dmerge incl; # convenience re-exports
      inherit (lib) blockTypes dataWith flakeModule;
      inherit grow growOn;
      inherit (paisano) pick harvest winnow;
      systems = nixpkgs.lib.systems.doubles;
    }
    # on our own account ...
    // (import ./dogfood.nix {
      inherit inputs growOn;
      inherit (lib) blockTypes;
      inherit (paisano) pick harvest;
    });
}
