let
  inherit (inputs) nixpkgs makes;
  inherit (inputs.nixpkgs) lib;

  makes' = lib.fix (
    lib.extends
    (
      _: _: {
        inherit inputs;
        inherit (nixpkgs) system;
        __nixpkgs__ = nixpkgs;
        __nixpkgsSrc__ = nixpkgs.path;
      }
    )
    (
      import (makes + /src/args/agnostic.nix) {inherit (nixpkgs) system;}
    )
    .__unfix__
  );
in
  lib.customisation.callPackageWith makes'
