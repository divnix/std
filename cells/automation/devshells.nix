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
      nixago = [
        (std.nixago.conform {configData = {inherit (inputs) cells;};})
        cell.nixago.treefmt
        cell.nixago.editorconfig
        cell.nixago.mdbook
        std.nixago.lefthook
        std.nixago.adrgen
      ];
      commands =
        [
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
        std.devshellProfiles.default
      ];
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
