{nixpkgs}: {
  runnables = import ./blocktypes/runnables.nix {inherit nixpkgs;};
  installables = import ./blocktypes/installables.nix {inherit nixpkgs;};
  functions = import ./blocktypes/functions.nix {inherit nixpkgs;};
  data = import ./blocktypes/data.nix {inherit nixpkgs;};
  devshells = import ./blocktypes/devshells.nix {inherit nixpkgs;};
  containers = import ./blocktypes/containers.nix {inherit nixpkgs;};
  files = import ./blocktypes/files.nix {inherit nixpkgs;};
  microvms = import ./blocktypes/microvms.nix {inherit nixpkgs;};
  nixago = import ./blocktypes/nixago.nix {inherit nixpkgs;};
  nomadJobManifests = import ./blocktypes/nomadJobManifests.nix {inherit nixpkgs;};
}
