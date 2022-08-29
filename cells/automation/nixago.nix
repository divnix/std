{
  inputs,
  cell,
}: let
  inherit (inputs) nixpkgs;
  inherit (inputs.cells) std;
in {
  treefmt = std.nixago.treefmt {
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
  editorconfig = std.nixago.editorconfig {
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
  mdbook = std.nixago.mdbook {
    configData = {
      book.title = "The Standard Book";
      preprocessor.mermaid.command = "mdbook-mermaid";
      output.html.additional-js = ["static/mermaid.min.js" "static/mermaid-init.js"];
    };
    packages = [nixpkgs.mdbook-mermaid];
  };
}
