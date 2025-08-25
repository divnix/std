# SPDX-FileCopyrightText: 2022 The Standard Authors
# SPDX-FileCopyrightText: 2022 Kevin Amado <kamadorueda@gmail.com>
#
# SPDX-License-Identifier: Unlicense
{
  description = "The Nix Flakes framework for perfectionists with deadlines";
  
  inputs = {
    # Core dependencies
    nixpkgs.url = "github:nixos/nixpkgs/release-23.11";  # override downstream with inputs.std.inputs.nixpkgs.follows = ...
    lib.url = "github:nix-community/nixpkgs.lib";
    
    # Framework dependencies
    paisano.url = "github:paisano-nix/core/0.2.0";
    paisano.inputs.nixpkgs.follows = "nixpkgs";
    paisano.inputs.yants.follows = "yants";
    paisano-tui = {
      url = "github:paisano-nix/tui/v0.5.0";
      flake = false; # we're after the source code, only
    };
    
    blank.url = "github:divnix/blank";
    yants = {
      url = "github:divnix/yants";
      inputs.nixpkgs.follows = "lib";
    };
    dmerge = {
      url = "github:divnix/dmerge/0.2.1";
      inputs.haumea.follows = "haumea";
      inputs.yants.follows = "yants";
      inputs.nixlib.follows = "lib";
    };
    haumea = {
      url = "github:nix-community/haumea/v0.2.2";
      inputs.nixpkgs.follows = "lib";
    };
    incl = {
      url = "github:divnix/incl";
      inputs.nixlib.follows = "lib";
    };
    
    # Development tools (previously "blank" and injected via sub-flakes, now included directly
    # to avoid self-referential sub-flake issues with Nix 2.18+)
    devshell.url = "github:numtide/devshell";
    devshell.inputs.nixpkgs.follows = "nixpkgs";
    
    nixago.url = "github:nix-community/nixago";
    nixago.inputs.nixpkgs.follows = "nixpkgs";
    nixago.inputs.nixago-exts.follows = "blank";
    
    n2c.url = "github:nlewo/nix2container";
    n2c.inputs.nixpkgs.follows = "nixpkgs";
    
    # Testing and infrastructure tools
    namaka.url = "github:nix-community/namaka/v0.2.0";
    namaka.inputs.haumea.follows = "haumea";
    namaka.inputs.nixpkgs.follows = "nixpkgs";
    
    # Additional tools (keep as blank for now, can be enabled if needed)
    terranix.follows = "blank";
    microvm.follows = "blank";
    makes.follows = "blank";
    arion.follows = "blank";
    flake-parts.follows = "blank";
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
      (import ./dogfood.nix (inputs
        // {
          std = std // {inherit (inputs.self) narHash;};
        }))
      std;
}
