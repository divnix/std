# SPDX-FileCopyrightText: 2022 The Standard Authors
# SPDX-FileCopyrightText: 2022 Kevin Amado <kamadorueda@gmail.com>
{ inputs
, ...
}:
let
  nixpkgs = inputs.nixpkgs;
  shell =
    nixpkgs.eggDerivation
      {
        name = "shell-0.4";
        src =
          nixpkgs.fetchegg
            {
              name = "shell";
              version = "0.4";
              sha256 = "sha256-TVZBzvlVegDLNU3Nz3w92E7imXGw6HYOq+vm2amM+/w=";
            };
        buildInputs = [ ];
      };
in
nixpkgs.stdenv.mkDerivation
  {
    name = "std";
    src = ./cli;
    dontInstall = true;
    nativeBuildInputs = [ nixpkgs.chicken ];
    buildInputs = with nixpkgs.chickenPackages.chickenEggs; [ matchable srfi-13 shell ];
    propagatedBuildInputs = [ nixpkgs.git ];
    buildPhase = ''
      mkdir -p $out/bin
      csc -o $out/bin/std -static "$src/cli.scm"
    '';
  }
