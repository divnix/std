{nixpkgs}: let
  l = nixpkgs.lib // builtins;
  /*
  Use the Nixago Blocktype for nixago pebbles.

  Use Nixago pebbles to ensure files are present
  or symlinked into your repository. You may typically
  use this for repo dotfiles.

  For more information, see: https://github.com/nix-community/nixago.

  Available actions:
    - ensure
    - explore

  */
  nixago = name: {
    inherit name;
    type = "nixago";
    actions = {
      system,
      flake,
      fragment,
      fragmentRelPath,
      target,
    }: [
      {
        name = "populate";
        description = "populate this nixago file into the repo";
        command = ''
          nix run ${flake}#${fragment}.install
        '';
      }
      {
        name = "explore";
        description = "interactively explore the nixago file";
        command = ''
          ${nixpkgs.legacyPackages.${system}.bat}/bin/bat "$(nix build --no-link --print-out-paths ${flake}#${fragment}.configFile)"
        '';
      }
    ];
  };
in
  nixago
