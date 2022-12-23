{
  inputs,
  cell,
}: let
  inherit (inputs) nixpkgs;
  inherit (inputs.cells) std;
  l = nixpkgs.lib // builtins;
in {
  adrgen = std.nixago.adrgen {
    configData = import ./nixago/adrgen.nix;
  };
  editorconfig = std.nixago.editorconfig {
    configData = import ./nixago/editorconfig.nix;
    hook.mode = "copy"; # already useful before entering the devshell
  };
  conform = std.nixago.conform {
    configData = import ./nixago/conform.nix;
  };
  lefthook = std.nixago.lefthook {
    configData = import ./nixago/lefthook.nix;
  };
  mdbook = std.nixago.mdbook {
    configData = import ./nixago/mdbook.nix;
    hook.mode = "copy"; # let CI pick it up outside of devshell
    packages = [std.packages.mdbook-kroki-preprocessor];
  };
  treefmt = std.nixago.treefmt {
    configData = import ./nixago/treefmt.nix;
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
    configData = import ./nixago/githubsettings.nix;
  };
  std-gh-action = std.nixago.std-gh-action;
}
