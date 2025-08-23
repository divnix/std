inputs: let
  removeBy = import ./cells/std/errors/removeBy.nix {inherit inputs;};
in {
  # fluidattacks/makes integration deprecation
  mkMakes = removeBy "2025-06-01" ''
    std.lib.dev.mkMakes is deprecated.
    
    The fluidattacks/makes project has been deprecated in favor of Nix Flakes.
    Please migrate your makes tasks to use native Nix derivations or other
    Standard-supported alternatives.
    
    For more information, see: https://github.com/fluidattacks/makes
  '';
}
