{nixpkgs}: {
  runnables = import ./clades/runnables.nix {inherit nixpkgs;};
  installables = import ./clades/installables.nix {inherit nixpkgs;};
  functions = import ./clades/functions.nix {inherit nixpkgs;};
  data = import ./clades/data.nix {inherit nixpkgs;};
  devshells = import ./clades/devshells.nix {inherit nixpkgs;};
  containers = import ./clades/containers.nix {inherit nixpkgs;};
  files = import ./clades/files.nix {inherit nixpkgs;};
}
