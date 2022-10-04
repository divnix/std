{
  inputs,
  cell,
}: let
  inherit (inputs) dmerge devshell nixago;
  nixpkgs = inputs.nixpkgs;

  l = nixpkgs.lib // builtins;

  requireInput = import ../errors/requireInput.nix;
in {
  mkShell = import ./mkShell.nix {inherit inputs cell;};
  mkNixago = import ./mkNixago.nix {inherit inputs cell;};

  fromMicrovmWith = inputs':
    import ./fromMicrovmWith.nix {
      inputs = requireInput {inputs = inputs';} "microvm" "github:astro/microvm.nix" "std.std.lib.fromMicrovmWith";
    };
  writeShellEntrypoint = inputs':
    import ./writeShellEntrypoint.nix {
      inputs = requireInput {inputs = inputs';} "n2c" "github:nlewo/nix2container" "std.std.lib.writeShellEntrypoint";
    };
  fromMakesWith = inputs':
    import ./fromMakesWith.nix {
      inputs = requireInput {inputs = inputs';} "makes" "github:fluidattacks/makes" "std.std.lib.fromMakesWith";
    };
}
