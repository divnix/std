{
  l,
  inputs,
}: let
  inherit (inputs) nixpkgs makes;

  makes' = l.fix (
    l.extends
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
  l.customisation.callPackageWith makes'
