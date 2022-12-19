{
  inputs,
  cell,
}: let
  inherit (inputs.cells.lib) dev ops;

  l = inputs.nixpkgs.lib // builtins;

  requireInput = import ../errors/requireInput.nix;

  inherit (import "${inputs.self}/deprecation.nix" inputs) warnMkMakes warnMkMicrovm warnNewLibCell;
in
  l.mapAttrs (_: warnNewLibCell) {
    inherit
      (dev)
      mkShell
      mkNixago
      mkMakes
      ;
    inherit
      (ops)
      mkMicrovm
      ;

    writeShellEntrypoint = inputs':
      import ../lib/ops/writeShellEntrypoint.nix {
        inputs = requireInput {inputs = inputs';} "n2c" "github:nlewo/nix2container" "std.std.lib.writeShellEntrypoint";
      };
    fromMicrovmWith = inputs':
      warnMkMicrovm
      import
      ../lib/ops/mkMakes.nix {
        inputs = requireInput {inputs = inputs';} "microvm" "github:astro/microvm.nix" "std.std.lib.fromMicrovmWith";
      };
    fromMakesWith = inputs':
      warnMkMakes
      import
      ../lib/ops/mkMicrovm.nix {
        inputs = requireInput {inputs = inputs';} "makes" "github:fluidattacks/makes" "std.std.lib.fromMakesWith";
      };

    mkDevelopDrv = import "${inputs.self}/src/devshell-drv.nix";
  }
