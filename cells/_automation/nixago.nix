{
  inputs,
  cell,
}: let
  inherit (inputs) nixpkgs;
  inherit (inputs.cells) std presets;
in {
  treefmt = presets.nixago.treefmt {
    configData.formatter = {
      go = {
        command = "gofmt";
        options = ["-w"];
        includes = ["*.go"];
      };
      prettier = {
        excludes = ["**.min.js"];
      };
    };
    packages = [nixpkgs.go];
  };
  editorconfig = presets.nixago.editorconfig {
    configData = {
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
  just = std.nixago.just {
    configData = {
      tasks = import ./tasks.nix;
    };
  };
  mdbook = presets.nixago.mdbook {
    output = "docs/book.toml";
    configData = {
      book.title = "The Standard Documentation";
      book.src = ".";
      preprocessor.mermaid.command = "mdbook-mermaid";
      output.html.additional-js = ["static/mermaid.min.js" "static/mermaid-init.js"];
      build.build-dir = "book";
    };
    packages = [nixpkgs.mdbook-mermaid];
  };
  githubsettings = presets.nixago.githubsettings {
    configData = {
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
}
