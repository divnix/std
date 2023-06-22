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

  outputs = inputs: let
    # bootstrap std
    fwlib = import ./src/std/fwlib.nix {
      inputs = inputs // {nixpkgs = inputs.nixpkgs.legacyPackages;};
      cell = {};
    };
    # load fwlib again through the framework
    # to enable input overloading for blocktypes
    std = pick (fwlib.grow {
      inherit inputs;
      cellsFrom = inputs.incl ./src ["std"];
      cellBlocks = [(fwlib.blockTypes.functions "fwlib")];
    }) ["std" "fwlib"];
    inherit (inputs.paisano) pick harvest;
  in
    std.growOn {
      inherit inputs;
      cellsFrom = ./src;
      cellBlocks = with std.blockTypes; [
        ## For downstream use

        # std
        (runnables "cli" {ci.build = true;})
        (functions "devshellProfiles")
        (functions "errors")

        # lib
        (functions "dev")
        (functions "ops")
        (nixago "cfg")

        # presets
        (data "templates")
        (nixago "nixago")

        ## For local use in the Standard repository

        # local
        (devshells "shells" {ci.build = true;})
        (nixago "configs")
        (containers "containers")
        (namaka "checks")
      ];
    }
    {
      # the framework's basic top-level tools
      inherit (inputs) yants dmerge incl;
      inherit (inputs.paisano) pick harvest winnow;
      inherit (std) blockTypes actions dataWith flakeModule grow growOn;
    }
    {
      # auxiliary outputs
      devShells = harvest inputs.self ["local" "shells"];
      packages = harvest inputs.self [["std" "cli"] ["std" "packages"]];
      templates = pick inputs.self ["std" "templates"];
      checks = pick inputs.self ["tests" "checks"];
    };
}
