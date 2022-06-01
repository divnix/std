{
  inputs,
  cell,
}: let
  l = nixpkgs.lib // builtins;
  inherit (inputs) nixpkgs;
in
  l.mapAttrs (_: cell.lib.mkShell) {
    default = {
      extraModulesPath,
      pkgs,
      ...
    }: {
      name = "Standard";
      packages = [
        # formatters
        nixpkgs.alejandra
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
        {
          package = nixpkgs.reuse;
          category = "legal";
        }
        {
          package = nixpkgs.delve;
          category = "cli-dev";
          name = "dlv";
        }
        {
          package = nixpkgs.go;
          category = "cli-dev";
        }
        {
          package = nixpkgs.gotools;
          category = "cli-dev";
        }
        {
          package = nixpkgs.gopls;
          category = "cli-dev";
        }
      ] ++ l.optionals nixpkgs.stdenv.isLinux [
        {
          package = nixpkgs.golangci-lint;
          category = "cli-dev";
        }
      ];
      imports = [
        "${extraModulesPath}/git/hooks.nix"
        cell.devshellProfiles.default
      ];
      git.hooks = {
        enable = true;
        pre-commit.text = builtins.readFile ./devshells/pre-commit.sh;
      };
    };
    checks = {pkgs, config, ...}: {
      name = "checks";
      imports = [
        cell.devshellProfiles.default
        cell.devshellProfiles.checks
      ];
    };
  }
