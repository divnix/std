{
  description = "Standard development shell";
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  inputs.devshell.url = "github:numtide/devshell?ref=refs/pull/169/head";
  inputs.treefmt.url = "github:numtide/treefmt";
  inputs.alejandra.url = "github:kamadorueda/alejandra";
  inputs.alejandra.inputs.treefmt.url = "github:divnix/blank";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.main.url = "path:../.";
  outputs = inputs: inputs.flake-utils.lib.eachSystem [ "x86_64-linux" "x86_64-darwin" ] (
    system: let
      inherit
        (inputs.main.deSystemize system inputs)
        main
        devshell
        nixpkgs
        alejandra
        treefmt
        ;
    in
      {
        devShells.__default = devshell.legacyPackages.mkShell (
          { extraModulesPath
          , pkgs
          , ...
          }:
          {
            name = "Standard";
            cellsFrom = "./cells";
            packages = [
              # formatters
              alejandra.defaultPackage
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
