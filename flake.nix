# SPDX-FileCopyrightText: 2022 The Standard Authors
# SPDX-FileCopyrightText: 2022 Kevin Amado <kamadorueda@gmail.com>
#
# SPDX-License-Identifier: Unlicense
{
  description = "The Nix Flakes framework for perfectionists with deadlines";
  # override downstream with inputs.std.inputs.nixpkgs.follows = ...
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  inputs.lib.url = "github:nix-community/nixpkgs.lib";
  inputs = {
    paisano.url = "github:paisano-nix/core";
    paisano.inputs.nixpkgs.follows = "nixpkgs";
    paisano.inputs.yants.follows = "yants";
    paisano-tui = {
      url = "github:paisano-nix/tui/0.2.0";
      flake = false; # we're after the source code, only
    };
  };
  inputs.blank.url = "github:divnix/blank";
  inputs.yants = {
    url = "github:divnix/yants";
    inputs.nixpkgs.follows = "lib";
  };
  inputs.dmerge = {
    url = "github:divnix/dmerge/0.2.1";
    inputs.haumea.follows = "haumea";
    inputs.yants.follows = "yants";
    inputs.nixlib.follows = "lib";
  };
  inputs.haumea = {
    url = "github:nix-community/haumea/v0.2.2";
    inputs.nixpkgs.follows = "lib";
  };
  inputs.incl = {
    url = "github:divnix/incl";
    inputs.nixlib.follows = "lib";
  };
  /*
  Auxiliar inputs used in builtin libraries or for the dev environment.
  */
  inputs = {
    # Placeholder inputs that can be overloaded via follows
    n2c.follows = "blank";
    devshell.follows = "blank";
    nixago.follows = "blank";
    terranix.follows = "blank";
    microvm.follows = "blank";
    makes.follows = "blank";
    arion.follows = "blank";
  };

  outputs = inputs: let
    # bootstrap std
    fwlib = import ./src/std/fwlib.nix {
      inputs = inputs // {nixpkgs = inputs.nixpkgs.legacyPackages;};
      cell = {};
    };
    # load fwlib again through the framework
    # to enable input overloading for blocktypes
    fwlib' = inputs.paisano.pick (fwlib.grow {
      inherit inputs;
      cellsFrom = inputs.incl ./src ["std"];
      cellBlocks = [(fwlib.blockTypes.functions "fwlib")];
    }) ["std" "fwlib"];

    std = {
      # the framework's basic top-level tools
      inherit (inputs) yants dmerge incl;
      inherit (inputs.paisano) pick harvest winnow;
      inherit (fwlib') blockTypes actions dataWith flakeModule grow growOn findTargets;
    };
  in
    assert inputs.nixpkgs.lib.assertMsg ((builtins.compareVersions builtins.nixVersion "2.13") >= 0) "The truth is: you'll need a newer nix version to use Standard (minimum: v2.13).";
      (import ./dogfood.nix (inputs // {inherit std;})) std;
}
