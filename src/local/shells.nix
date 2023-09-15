{
  inputs,
  cell,
}: let
  inherit (inputs) nixpkgs namaka;
  inherit (inputs.nixpkgs.lib) mapAttrs optionals;
  inherit (inputs.std) std;
  inherit (inputs.std.lib.dev) mkShell;
  inherit (cell) configs;
in
  mapAttrs (_: mkShell) rec {
    default = {...}: {
      name = "Standard";
      nixago = [
        configs.conform
        configs.treefmt
        configs.editorconfig
        configs.githubsettings
        configs.lefthook
        configs.adrgen
        configs.cog
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
        ++ optionals nixpkgs.stdenv.isLinux [
          {
            package = nixpkgs.golangci-lint;
            category = "cli-dev";
          }
        ];
      imports = [std.devshellProfiles.default book];
    };

    book = {...}: {
      nixago = [configs.mdbook];
    };
  }
