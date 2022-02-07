{
  description = "Standard development shell";
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  inputs.devshell.url = "github:numtide/devshell?ref=refs/pull/169/head";
  inputs.treefmt.url = "github:numtide/treefmt";
  inputs.alejandra.url = "github:kamadorueda/alejandra";
  inputs.alejandra.inputs.treefmt.url = "github:divnix/blank";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.std.url = "path:../.";
  outputs = inputs: inputs.flake-utils.lib.eachSystem [ "x86_64-linux" "x86_64-darwin" ] (
    system: let
      stdProfiles = inputs.std.devshellProfiles.${system};
      devshell = inputs.devshell.legacyPackages.${system};
      nixpkgs = inputs.nixpkgs.legacyPackages.${system};
      alejandra = inputs.alejandra.defaultPackage.${system};
      treefmt = inputs.treefmt.defaultPackage.${system};
    in
      {
        devShells.__default = devshell.mkShell (
          { extraModulesPath
          , pkgs
          , ...
          }:
          {
            name = "Standard";
            cellsFrom = "./cells";
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
              {
                package = nixpkgs.reuse;
                category = "legal";
              }
            ];
            imports = [ "${extraModulesPath}/git/hooks.nix" stdProfiles.std ];
            git.hooks = {
              enable = true;
              pre-commit.text = builtins.readFile ./pre-commit.sh;
            };
          }
        );
      }
  );
}
