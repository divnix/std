{nixpkgs}: let
  mkCommand = system: type: args:
    args
    // {
      command = (nixpkgs.legacyPackages.${system}.writeShellScript "${type}-${args.name}" args.command).overrideAttrs (self: {
        passthru =
          self.passthru
          or {}
          // nixpkgs.lib.optionalAttrs (args ? proviso) {
            proviso = builtins.toFile "${args.name}-proviso" args.proviso;
          }
          // nixpkgs.lib.optionalAttrs (args ? targetDrv) {
            inherit (args) targetDrv;
          };
      });
    };
in {
  runnables = import ./blocktypes/runnables.nix {inherit nixpkgs mkCommand;};
  installables = import ./blocktypes/installables.nix {inherit nixpkgs mkCommand;};
  functions = import ./blocktypes/functions.nix {inherit nixpkgs mkCommand;};
  data = import ./blocktypes/data.nix {inherit nixpkgs mkCommand;};
  devshells = import ./blocktypes/devshells.nix {inherit nixpkgs mkCommand;};
  containers = import ./blocktypes/containers.nix {inherit nixpkgs mkCommand;};
  files = import ./blocktypes/files.nix {inherit nixpkgs mkCommand;};
  microvms = import ./blocktypes/microvms.nix {inherit nixpkgs mkCommand;};
  nixago = import ./blocktypes/nixago.nix {inherit nixpkgs mkCommand;};
  arion = import ./blocktypes/arion.nix {inherit nixpkgs mkCommand;};
  nomadJobManifests = import ./blocktypes/nomadJobManifests.nix {inherit nixpkgs mkCommand;};
}
