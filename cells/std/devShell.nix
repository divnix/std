{ inputs
, system
}:
let
  nixpkgs = inputs.nixpkgs.extend inputs.devshell.overlay;
  alejandra = inputs.alejandra.defaultPackage.${ system.host.system };
  treefmt = inputs.treefmt.defaultPackage.${ system.host.system };
in
  nixpkgs.devshell.mkShell
    (
      { extraModulesPath
      , pkgs
      , ...
      }:
      {
        name = "std";
        packages = [
          # formatters
          alejandra
          nixpkgs.shfmt
          nixpkgs.nodePackages.prettier
        ];
        commands = [
          {
            package = nixpkgs.treefmt;
            category = "formatters";
          }
          {
            package = nixpkgs.editorconfig-checker;
            category = "formatters";
          }
        ];
        imports = [ "${ extraModulesPath }/git/hooks.nix" ];
        git.hooks = {
          enable = true;
          pre-commit.text = builtins.readFile ./devShell/pre-commit.sh;
        };
      }
    )
