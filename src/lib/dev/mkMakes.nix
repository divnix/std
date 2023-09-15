let
  inherit (inputs.cells.std.errors) requireInput;
  inherit (requireInput "makes" "github:fluidattacks/makes" "std.lib.dev.mkMakes") nixpkgs makes;
  inherit (nixpkgs) lib;

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
