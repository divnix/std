{
  inputs,
  cell,
}: let
  inherit (inputs) nixpkgs;
  inherit (inputs.cells) lib;
  l = nixpkgs.lib // builtins;
  inherit (import (inputs.self + /deprecation.nix) inputs) warnNixagoOutfactored;
in
  l.mapAttrs (_: warnNixagoOutfactored) {
    adrgen = lib.cfg.adrgen {
      data = import ./nixago/adrgen.nix;
    };
    editorconfig = lib.cfg.editorconfig {
      data = import ./nixago/editorconfig.nix;
      hook.mode = "copy"; # already useful before entering the devshell
    };
    conform = lib.cfg.conform {
      data = import ./nixago/conform.nix;
    };
    lefthook = lib.cfg.lefthook {
      data = import ./nixago/lefthook.nix;
    };
    mdbook = lib.cfg.mdbook {
      data = import ./nixago/mdbook.nix;
      hook.mode = "copy"; # let CI pick it up outside of devshell
      packages = [std.packages.mdbook-kroki-preprocessor];
    };
    treefmt = lib.cfg.treefmt {
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
    githubsettings = lib.cfg.githubsettings {
      data = import ./nixago/githubsettings.nix;
    };
  }
