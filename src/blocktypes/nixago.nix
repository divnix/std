deSystemize: nixpkgs': let
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
    }: let
      l = nixpkgs.lib // builtins;
      nixpkgs = deSystemize system nixpkgs'.legacyPackages;
    in [
      {
        name = "populate";
        description = "populate this nixago file into the repo";
        command = nixpkgs.writeShellScriptWithPrjRoot "populate" ''
          nix run "$PRJ_ROOT#${fragment}.install
        '';
      }
      {
        name = "explore";
        description = "interactively explore the nixago file";
        command = nixpkgs.writeShellScriptWithPrjRoot "explore" ''
          ${nixpkgs.bat}/bin/bat "$(nix build --no-link --print-out-paths "$PRJ_ROOT#${fragment}.configFile)"
        '';
      }
    ];
  };
in
  nixago
