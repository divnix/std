{
  inputs,
  cell,
}: let
  inherit (inputs) nixpkgs;
  inherit (inputs.std.data) configs;
  inherit (inputs.std.lib.dev) mkNixago;
in {
  cog = (mkNixago configs.cog) {
    data.changelog = {
      remote = "github.com";
      repository = "std";
      owner = "divnix";
    };
  };
  treefmt = (mkNixago configs.treefmt) {
    data = {
      global.excludes = ["src/std/templates/**"];
      formatter = {
        go = {
          command = "gofmt";
          options = ["-w"];
          includes = ["*.go"];
        };
        prettier = {
          excludes = ["**.min.js"];
        };
      };
    };
    packages = [nixpkgs.go];
  };
  editorconfig = (mkNixago configs.editorconfig) {
    data = {
      "*.xcf" = {
        charset = "unset";
        end_of_line = "unset";
        insert_final_newline = "unset";
        trim_trailing_whitespace = "unset";
        indent_style = "unset";
        indent_size = "unset";
      };
      "{*.go,go.mod}" = {
        indent_style = "tab";
        indent_size = 4;
      };
    };
  };
  mdbook = (mkNixago configs.mdbook) {
    data = {
      book.title = "The Standard Documentation";
      preprocessor.paisano-preprocessor = {
        multi = [
          {
            chapter = "Cell: lib";
            cell = "lib";
          }
          {
            chapter = "Cell: std";
            cell = "std";
          }
        ];
      };
      output.html = {
        additional-js = ["docs/theme/pagetoc.js"];
        additional-css = ["docs/theme/pagetoc.css"];
      };
    };
  };

  githubsettings = (mkNixago configs.githubsettings) {
    data = {
      repository = {
        name = "std";
        homepage = "https://std.divnix.com";
        description = "A DevOps framework for the SDLC with the power of Nix and Flakes. Good for keeping deadlines!";
        topics = "nix, nix-flakes, devops, sdlc";
        default_branch = "main";
        allow_squash_merge = true;
        allow_merge_commit = false;
        allow_rebase_merge = true;
        delete_branch_on_merge = true;
      };
      milestones = [
        {
          title = "Release v1";
          description = ":dart:";
          state = "open";
        }
      ];
    };
  };
  adrgen = (mkNixago configs.adrgen) {};
  conform = (mkNixago configs.conform) {
    data = {inherit (inputs) cells;};
  };
  lefthook = (mkNixago configs.lefthook) {};
}
