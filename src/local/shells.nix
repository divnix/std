{
  inputs,
  cell,
}: let
  l = nixpkgs.lib // builtins;
  inherit (inputs) nixpkgs namaka;
  inherit (inputs.std) std lib;
in
  l.mapAttrs (_: lib.dev.mkShell) rec {
    default = {...}: {
      name = "Standard";
      nixago = [
        ((lib.dev.mkNixago lib.cfg.conform)
          {data = {inherit (inputs) cells;};})
        ((lib.dev.mkNixago lib.cfg.treefmt)
          cell.configs.treefmt)
        ((lib.dev.mkNixago lib.cfg.editorconfig)
          cell.configs.editorconfig)
        ((lib.dev.mkNixago lib.cfg.just)
          cell.configs.just)
        ((lib.dev.mkNixago lib.cfg.githubsettings)
          cell.configs.githubsettings)
        (lib.dev.mkNixago lib.cfg.lefthook)
        (lib.dev.mkNixago lib.cfg.adrgen)
        (lib.dev.mkNixago cell.configs.cog)
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
          {
            package = namaka.packages.default;
            category = "nix-testing";
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
        ((lib.dev.mkNixago lib.cfg.mdbook)
          cell.configs.mdbook)
      ];
    };
  }
