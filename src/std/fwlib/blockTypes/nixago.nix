{root}:
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
let
  inherit (root) mkCommand;
in
  name: {
    inherit name;
    type = "nixago";
    actions = {
      currentSystem,
      fragment,
      fragmentRelPath,
      target,
      inputs,
    }: let
      pkgs = inputs.nixpkgs.${currentSystem};
    in [
      (mkCommand currentSystem "populate" "populate this nixago file into the repo" [] ''
        ${target.install}/bin/nixago_shell_hook
      '' {})
      (mkCommand currentSystem "explore" "interactively explore the nixago file" [pkgs.bat] ''
        bat "${target.config}"
      '' {})
    ];
  }
