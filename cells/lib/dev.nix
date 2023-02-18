{
  inputs,
  cell,
}: let
  inherit (inputs.cells.std.errors) requireInput;
in {
  mkShell = import ./dev/mkShell.nix {inherit inputs cell;};
  mkNixago = import ./dev/mkNixago.nix {inherit inputs cell;};

  mkMakes = import ./dev/mkMakes.nix {
    l = inputs.nixpkgs.lib // builtins;
    inputs = requireInput "makes" "github:fluidattacks/makes" "std.lib.dev.mkMakes";
  };

  mkArion = import ./dev/mkArion.nix {
    l = inputs.nixpkgs.lib // builtins;
    inputs = requireInput "arion" "github:hercules-ci/arion" "std.lib.dev.mkArion";
  };

  mkDevenvSrv = import ./dev/mkDevenvSrv.nix {
    l = inputs.nixpkgs.lib // builtins;
    inputs = requireInput "devenv" "github:cachix/devenv?dir=src/modules" "std.lib.dev.mkDevenvSrv";
  };
}
