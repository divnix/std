# SPDX-FileCopyrightText: 2022 The Standard Authors
# SPDX-FileCopyrightText: 2022 Kevin Amado <kamadorueda@gmail.com>
{ inputs
, system
}:
let
  nixpkgs = inputs.nixpkgs;
in
{
  "" =
    let
      inherit (nixpkgs.chickenPackages) chickenEggs;
      shell = nixpkgs.eggDerivation {
        name = "shell-0.4";
        src = nixpkgs.fetchegg {
          name = "shell";
          version = "0.4";
          sha256 = "sha256-TVZBzvlVegDLNU3Nz3w92E7imXGw6HYOq+vm2amM+/w=";
        };
        buildInputs = [ ];
      };
      lazy-seq = nixpkgs.eggDerivation {
        name = "lazy-seq-2";
        src = nixpkgs.fetchegg {
          name = "lazy-seq";
          version = "2";
          sha256 = "sha256-emjinMqdMpeaU9O7qN4v/xiJGfZyHC9YTMQlkk/aoB0=";
        };
        buildInputs = with chickenEggs; [ srfi-1 ];
      };
      trie = nixpkgs.eggDerivation {
        name = "trie-2";
        src = nixpkgs.fetchegg {
          name = "trie";
          version = "2";
          sha256 = "sha256-kdsywnZqJVFO+2vCba5BbpLW4azODO70LhgqQWzn65I=";
        };
        buildInputs = with chickenEggs; [ srfi-1 ];
      };
      srfi-69 = nixpkgs.eggDerivation {
        name = "srfi-69-0.4.3";
        src = nixpkgs.fetchegg {
          name = "srfi-69";
          version = "0.4.3";
          sha256 = "sha256-ejqj0EghSr7Ac4/fD5AHiRgbrmpJd9bVrTcPZknx9oY=";
          # sha256 = nixpkgs.lib.fakeSha256;
        };
      };
      comparse = nixpkgs.eggDerivation {
        name = "comparse-3";
        src = nixpkgs.fetchegg {
          name = "comparse";
          version = "3";
          sha256 = "sha256-gpGLRF1cTvkEjEhV95jwaPpGI6tXoP2WqwSCZILShnU=";
        };
        buildInputs =
          with chickenEggs; [ lazy-seq trie matchable srfi-13 srfi-69 ];
      };
      medea = nixpkgs.eggDerivation {
        name = "medea-4";
        src = nixpkgs.fetchegg {
          name = "medea";
          version = "4";
          sha256 = "sha256-29AZOHuyacFeNS1dmH9qOxDB0IeyM8Lz0z1JQitdKOc=";
        };
        buildInputs = [ comparse ];
      };
      iset = nixpkgs.eggDerivation {
        name = "iset";
        src = nixpkgs.fetchegg {
          name = "iset";
          version = "2.2";
          sha256 = "sha256-P49qdCSmd/5OFVe2DcgkhW3QA/Jyr+Wwtd1wdkBj03k=";
        };
      };
      regex = nixpkgs.eggDerivation {
        name = "regex";
        src = nixpkgs.fetchegg {
          name = "regex";
          version = "2.0";
          sha256 = "sha256-kkgEI2EA/XFTlyxdF9zG/EdoRzJr+474e9iXlFvO+GE=";
        };
      };
      utf8 = nixpkgs.eggDerivation {
        name = "utf8";
        src = nixpkgs.fetchegg {
          name = "utf8";
          version = "3.6.3";
          sha256 = "sha256-PJ53wuNStzziNhrG9Uu14Dc3mcPuncgodZM/Zxdtgbw=";
        };
        buildInputs = with chickenEggs; [ iset srfi-69 regex ];
      };
      fmt = nixpkgs.eggDerivation {
        name = "fmt";
        src = nixpkgs.fetchegg {
          name = "fmt";
          version = "0.8.11";
          sha256 = "sha256-nmDj5Xmo29V+nLnxsIz5/bD72LtyyYWLNU4/CmFaGVg=";
        };
        buildInputs = with chickenEggs; [ srfi-1 srfi-13 srfi-69 utf8 ];
      };
    in
      nixpkgs.stdenv.mkDerivation {
        name = "std";
        meta.description = "nix shortcut for projects that conform to Standard";
        src = ./.;
        dontInstall = true;
        nativeBuildInputs = [ nixpkgs.chicken ];
        buildInputs =
          with nixpkgs.chickenPackages.chickenEggs;
          [ matchable srfi-13 shell medea fmt ];
        propagatedBuildInputs = [ nixpkgs.git ];
        buildPhase = ''
          mkdir -p $out/bin
          csc -o $out/bin/std -static "$src/main.scm"
        '';
      };
}
