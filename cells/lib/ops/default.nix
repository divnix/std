{
  inputs,
  cell,
}: let
  inherit (inputs.cells.std.errors) requireInput;
  inherit (import "${inputs.self}/deprecation.nix" inputs) warnWriteShellEntrypoint;
in {
  mkMicrovm = import ./mkMicrovm.nix {
    inputs = requireInput "microvm" "github:astro/microvm.nix" "std.lib.ops.mkMicrovm";
  };

  mkOperable = import ./mkOperable.nix {inherit inputs cell;};
  mkOperableScript = import ./mkOperableScript.nix {inherit inputs cell;};
  mkSetup = import ./mkSetup.nix {inherit inputs cell;};
  mkUser = import ./mkUser.nix {inherit inputs cell;};
  writeScript = import ./writeScript.nix {inherit inputs cell;};

  mkOCI = import ./mkOCI.nix {inherit inputs cell;};
  mkDevOCI = import ./mkDevOCI.nix {inherit inputs cell;};
  mkStandardOCI = import ./mkStandardOCI.nix {inherit inputs cell;};
}
