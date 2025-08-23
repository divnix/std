let
  inherit (inputs.cells.std.errors) requireInput;
  inherit (requireInput "makes" "github:fluidattacks/makes" "std.lib.dev.mkMakes") nixpkgs makes;
  inherit (inputs.nixpkgs.lib) customisation fix extends;
  
  # Show deprecation warning
  _ = builtins.trace ''
    ⚠️  DEPRECATION WARNING: std.lib.dev.mkMakes is deprecated
    
    The fluidattacks/makes project has been deprecated in favor of Nix Flakes.
    Scheduled for removal: 2025-06-01
    
    Please migrate your makes tasks to use native Nix derivations or other
    Standard-supported alternatives.
    
    For more information, see: https://github.com/fluidattacks/makes
  '' null;
in
  customisation.callPackageWith (fix (
    extends (
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
  ))
