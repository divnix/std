{
  inputs,
  cell,
}: let
  l = nixpkgs.lib // builtins;
  inherit (inputs) nixpkgs;
  inherit (inputs.cells) std;
in
  l.mapAttrs (_: std.lib.mkShell) {
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
      commands =
        [
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
        ]
        ++ l.optionals nixpkgs.stdenv.isLinux [
          {
            package = nixpkgs.golangci-lint;
            category = "cli-dev";
          }
        ];
      imports = [
        "${extraModulesPath}/git/hooks.nix"
        std.devshellProfiles.default
      ];
      git.hooks = {
        enable = true;
        pre-commit.text = builtins.readFile ./devshells/pre-commit.sh;
      };
    };
    checks = {
      pkgs,
      config,
      ...
    }: {
      name = "checks";
      imports = [
        std.devshellProfiles.default
      ];
      commands = [
        {
          name = "clade-data";
          command = "cat $(std //tests/data/example:write)";
        }
        {
          name = "clade-devshells";
          command = "std //std/devshell/default:enter -- echo OK";
        }
        {
          name = "clade-runnables";
          command = "std //std/cli/default:run -- std OK";
        }
      ];
    };
  }
