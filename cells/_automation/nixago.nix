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
    configData = {
      book.title = "The Standard Book";
      preprocessor.mermaid.command = "mdbook-mermaid";
      output.html.additional-js = ["static/mermaid.min.js" "static/mermaid-init.js"];
    };
    packages = [nixpkgs.mdbook-mermaid];
  };
}
