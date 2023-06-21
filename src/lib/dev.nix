{
  inputs,
  cell,
}: let
  inherit (inputs.cells.std.errors) requireInput;
in {
  mkShell = import ./dev/mkShell.nix {
    inputs = requireInput "devshell" "github:numtide/devshell" "std.lib.dev.mkShell";
    inherit cell;
  };
  mkNixago = import ./dev/mkNixago.nix {
    inputs = requireInput "nixago" "github:nix-community/nixago" "std.lib.dev.mkNixago";
    inherit cell;
  };

  mkMakes = import ./dev/mkMakes.nix {
    l = inputs.nixpkgs.lib // builtins;
    inputs = requireInput "makes" "github:fluidattacks/makes" "std.lib.dev.mkMakes";
  };

  mkArion = import ./dev/mkArion.nix {
    l = inputs.nixpkgs.lib // builtins;
    inputs = requireInput "arion" "github:hercules-ci/arion" "std.lib.dev.mkArion";
  };
}
