{
  inputs,
  l,
}: let
  inherit (inputs) nixpkgs devenv;

  listEntries = path:
    map (name: path + "/${name}") (builtins.attrNames (builtins.readDir path));
in
  module:
    (l.evalModules {
      modules = [
        (devenv.modules + /top-level.nix)
        ({config, ...}: {
          disabledModules =
            []
            ++ (listEntries (devenv.modules + /integrations))
            ++ (listEntries (devenv.modules + /languages));

          devenv.flakesIntegration = true;
          devenv.cliVersion = config.devenv.latestVersion;
          env.DEVENV_ROOT = l.mkForce "$PRJ_ROOT";
          env.DEVENV_DOTFILE = l.mkForce (config.env.DEVENV_ROOT + "/.std");
        })
        module
      ];
      specialArgs = {
        pkgs = nixpkgs;
        inherit inputs;
      };
    })
    .config
