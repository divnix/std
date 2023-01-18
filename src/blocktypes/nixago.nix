{
  nixpkgs,
  mkCommand,
}: let
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
      fragment,
      fragmentRelPath,
      target,
    }: [
      (mkCommand system {
        name = "populate";
        description = "populate this nixago file into the repo";
        command = ''
          ${target.install}/bin/nixago_shell_hook
        '';
      })
      (mkCommand system {
        name = "explore";
        description = "interactively explore the nixago file";
        command = ''
          ${nixpkgs.legacyPackages.${system}.bat}/bin/bat "${target.configFile}"
        '';
      })
    ];
  };
in
  nixago
