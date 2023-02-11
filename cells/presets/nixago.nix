{
  inputs,
  cell,
}: let
  inherit (inputs) nixpkgs;
  inherit (inputs.cells) std;
  l = nixpkgs.lib // builtins;
  inherit (import (inputs.self + /deprecation.nix) inputs) warnNixagoOutfactored;
in
  l.mapAttrs (_: warnNixagoOutfactored) {
    adrgen = std.nixago.adrgen {
      data = import ./nixago/adrgen.nix;
    };
    editorconfig = std.nixago.editorconfig {
      data = import ./nixago/editorconfig.nix;
      hook.mode = "copy"; # already useful before entering the devshell
    };
    conform = std.nixago.conform {
      data = import ./nixago/conform.nix;
    };
    lefthook = std.nixago.lefthook {
      data = import ./nixago/lefthook.nix;
    };
    mdbook = std.nixago.mdbook {
      data = import ./nixago/mdbook.nix;
      hook.mode = "copy"; # let CI pick it up outside of devshell
      packages = [std.packages.mdbook-kroki-preprocessor];
    };
    treefmt = std.nixago.treefmt {
      data = import ./nixago/treefmt.nix;
      packages = [
        nixpkgs.alejandra
        nixpkgs.nodePackages.prettier
        nixpkgs.nodePackages.prettier-plugin-toml
        nixpkgs.shfmt
      ];
      devshell.startup.prettier-plugin-toml = l.stringsWithDeps.noDepEntry ''
        export NODE_PATH=${nixpkgs.nodePackages.prettier-plugin-toml}/lib/node_modules:$NODE_PATH
      '';
    };
    githubsettings = std.nixago.githubsettings {
      data = import ./nixago/githubsettings.nix;
    };
  }
