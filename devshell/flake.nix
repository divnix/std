{
  description = "Standard development shell";
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  inputs.devshell.url = "github:numtide/devshell";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.main.url = "path:../.";
  outputs = inputs:
    inputs.flake-utils.lib.eachSystem ["x86_64-linux" "x86_64-darwin"] (
      system: let
        inherit (inputs.main.deSystemize system inputs) main devshell nixpkgs;
      in {
        devShells.default = devshell.legacyPackages.mkShell (
          {
            extraModulesPath,
            pkgs,
            ...
          }: {
            name = "Standard";
            cellsFrom = "./cells";
            packages = [
              # formatters
              nixpkgs.legacyPackages.alejandra
              nixpkgs.legacyPackages.shfmt
              nixpkgs.legacyPackages.nodePackages.prettier
            ];
            commands = [
              {
                package = nixpkgs.legacyPackages.treefmt;
                category = "formatters";
              }
              {
                package = nixpkgs.legacyPackages.editorconfig-checker;
                category = "formatters";
              }
              {
                package = nixpkgs.legacyPackages.reuse;
                category = "legal";
              }
              {
                package = nixpkgs.legacyPackages.delve;
                category = "cli-dev";
                name = "dlv";
              }
              {
                package = nixpkgs.legacyPackages.go;
                category = "cli-dev";
              }
              {
                package = nixpkgs.legacyPackages.gotools;
                category = "cli-dev";
              }
              {
                package = nixpkgs.legacyPackages.gopls;
                category = "cli-dev";
              }
              {
                package = nixpkgs.legacyPackages.golangci-lint;
                category = "cli-dev";
              }
            ];
            imports = [
              "${extraModulesPath}/git/hooks.nix"
              main.std.devshellProfiles.default
            ];
            git.hooks = {
              enable = true;
              pre-commit.text = builtins.readFile ./pre-commit.sh;
            };
          }
        );
      }
    );
}
