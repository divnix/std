{ inputs, ... }:

inputs.nixpkgs.devshell.mkShell
  (
    { extraModulesPath, pkgs, ... }:
    {
      name = "std";
      packages = with pkgs; [
        # formatters
        shfmt
        nodePackages.prettier
        alejandra
      ];

      commands = [
        { package = "treefmt"; category = "formatters"; }
        { package = "editorconfig-checker"; category = "formatters"; }
      ];

      imports = [ "${extraModulesPath}/git/hooks.nix" ];
      git.hooks = {
        enable = true;
        pre-commit.text = builtins.readFile ./devShell/pre-commit.sh;
      };
    }
  )
