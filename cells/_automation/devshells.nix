{
  inputs,
  cell,
}: let
  l = nixpkgs.lib // builtins;
  inherit (inputs) nixpkgs;
  inherit (inputs.cells) std lib;
in
  l.mapAttrs (_: lib.dev.mkShell) rec {
    default = {...}: {
      name = "Standard";
      nixago = [
        (lib.cfg.conform {data = {inherit (inputs) cells;};})
        (lib.cfg.treefmt cell.configs.treefmt)
        (lib.cfg.editorconfig cell.configs.editorconfig)
        (lib.cfg.just cell.configs.just)
        (lib.cfg.githubsettings cell.configs.githubsettings)
        lib.cfg.lefthook
        lib.cfg.adrgen
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
      imports = [std.devshellProfiles.default book];
    };

    book = {...}: {
      nixago = [
        (lib.cfg.mdbook cell.configs.mdbook)
      ];
    };

    checks = {...}: {
      name = "checks";
      imports = [std.devshellProfiles.default];
      commands = [
        {
          name = "blocktype-data";
          command = "cat $(std //_tests/data/example:write)";
        }
        {
          name = "blocktype-devshells";
          command = "std //_automation/devshell/default:enter -- echo OK";
        }
        {
          name = "blocktype-runnables";
          command = "std //std/cli/default:run -- std OK";
        }
      ];
    };
  }
