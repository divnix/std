# SPDX-FileCopyrightText: 2022 The Standard Authors
# SPDX-FileCopyrightText: 2022 Kevin Amado <kamadorueda@gmail.com>
#
# SPDX-License-Identifier: Unlicense
{ inputs
, system
}:
let
  nixpkgs = inputs.nixpkgs.extend inputs.devshell.overlay;
  alejandra = inputs.alejandra.defaultPackage.${system.host.system};
  treefmt = inputs.treefmt.defaultPackage.${system.host.system};
  stdProfile = inputs.self.devshellProfiles.${system.host.system}.std;
in
{
  "" =
    nixpkgs.devshell.mkShell
      (
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
          imports = [ "${extraModulesPath}/git/hooks.nix" stdProfile ];
          git.hooks = {
            enable = true;
            pre-commit.text = builtins.readFile ./devShells/pre-commit.sh;
          };
        }
      );
}
