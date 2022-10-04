{
  inputs,
  cell,
}: let
  inherit (inputs) dmerge devshell nixago;
  nixpkgs = inputs.nixpkgs;

  l = nixpkgs.lib // builtins;

  requireInput = import ../errors/requireInput.nix;

  inherit (import "${inputs.self}/deprecation.nix" inputs) warnMkMakes warnMkMicrovm;
in {
  mkShell = import ./mkShell.nix {inherit inputs cell;};
  mkNixago = import ./mkNixago.nix {inherit inputs cell;};

  mkMicrovm = import ./mkMicrovm.nix {
    inputs = cell.errors.requireInput "microvm" "github:astro/microvm.nix" "std.std.lib.mkMicrovm";
  };
  writeShellEntrypoint = inputs':
    import ./writeShellEntrypoint.nix {
      inputs = requireInput {inputs = inputs';} "n2c" "github:nlewo/nix2container" "std.std.lib.writeShellEntrypoint";
    };
  mkMakes = import ./mkMakes.nix {
    inputs = cell.errors.requireInput "makes" "github:fluidattacks/makes" "std.std.lib.mkMakes";
  };

  fromMicrovmWith = inputs':
    warnMkMicrovm
    import
    ./mkMicrovm.nix {
      inputs = requireInput {inputs = inputs';} "microvm" "github:astro/microvm.nix" "std.std.lib.fromMicrovmWith";
    };
  fromMakesWith = inputs':
    warnMkMakes
    import
    ./mkMakes.nix {
      inputs = requireInput {inputs = inputs';} "makes" "github:fluidattacks/makes" "std.std.lib.fromMakesWith";
    };
}
