{nixpkgs}: let
  sharedActions = import ./actions.nix {inherit nixpkgs;};
  mkCommand = import ./mkCommand.nix {inherit nixpkgs;};
in {
  runnables = import ./blocktypes/runnables.nix {inherit nixpkgs mkCommand sharedActions;};
  installables = import ./blocktypes/installables.nix {inherit nixpkgs mkCommand sharedActions;};
  functions = import ./blocktypes/functions.nix {inherit nixpkgs mkCommand;};
  data = import ./blocktypes/data.nix {inherit nixpkgs mkCommand;};
  devshells = import ./blocktypes/devshells.nix {inherit nixpkgs mkCommand sharedActions;};
  containers = import ./blocktypes/containers.nix {inherit nixpkgs mkCommand sharedActions;};
  files = import ./blocktypes/files.nix {inherit nixpkgs mkCommand;};
  microvms = import ./blocktypes/microvms.nix {inherit nixpkgs mkCommand;};
  nixago = import ./blocktypes/nixago.nix {inherit nixpkgs mkCommand;};
  arion = import ./blocktypes/arion.nix {inherit nixpkgs mkCommand;};
  nomadJobManifests = import ./blocktypes/nomadJobManifests.nix {inherit nixpkgs mkCommand;};
  pkgs = import ./blocktypes/pkgs.nix {};
}
