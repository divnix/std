/*
  This file holds configuration data for repo dotfiles.

  Q: Why not just put the put the file there?

  A:
   (1) dotfile proliferation
   (2) have all the things in one place / format
   (3) potentially share / re-use configuration data - keeping it in sync
*/
{ inputs
, cell
,
}:
let
  inherit (inputs.std.data) configs;
  inherit (inputs.std.lib.dev) mkNixago;
in
{
  # Tool Homepage: https://editorconfig.org/
  editorconfig = (mkNixago configs.editorconfig) {
    # see defaults at https://github.com/divnix/std/blob/5ce7c9411337af3cb299bc9b6cc0dc88f4c1ee0e/src/data/configs/editorconfig.nix
    data = { };
  };

  # Tool Homepage: https://numtide.github.io/treefmt/
  treefmt = (mkNixago configs.treefmt) {
    # see defaults at https://github.com/divnix/std/blob/5ce7c9411337af3cb299bc9b6cc0dc88f4c1ee0e/src/data/configs/treefmt.nix
    data = { };
  };

  conform = (mkNixago configs.conform) {
    data = { inherit (inputs) cells; };
  };

  # Tool Homepage: https://github.com/evilmartians/lefthook
  lefthook = (mkNixago configs.lefthook) {
    # see defaults at https://github.com/divnix/std/blob/5ce7c9411337af3cb299bc9b6cc0dc88f4c1ee0e/src/data/configs/lefthook.nix
    data = { };
  };
  githubsettings = (mkNixago configs.githubsettings) {
    # see defaults at https://github.com/divnix/std/blob/5ce7c9411337af3cb299bc9b6cc0dc88f4c1ee0e/src/data/configs/githubsettings.nix
    data = {
      repository = {
        name = "CONFIGURE-ME";
        inherit (import (inputs.self + /flake.nix)) description;
        homepage = "CONFIGURE-ME";
        topics = "CONFIGURE-ME";
        default_branch = "main";
        allow_squash_merge = false;
        allow_merge_commit = false;
        allow_rebase_merge = true;
        delete_branch_on_merge = true;
        private = true;
        has_issues = false;
        has_projects = false;
        has_wiki = false;
        has_downloads = false;
      };
    };
  };
  # Tool Homepage: https://rust-lang.github.io/mdBook/
  mdbook = (mkNixago configs.mdbook) {
    # see defaults at https://github.com/divnix/std/blob/5ce7c9411337af3cb299bc9b6cc0dc88f4c1ee0e/src/data/configs/mdbook.nix
    data = {
      book.title = "CONFIGURE-ME";
      preprocessor.paisano-preprocessor = {
        multi = [
          {
            chapter = "Cell: repo";
            cell = "repo";
          }
        ];
      };
    };
  };
}
