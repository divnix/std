{
  inputs,
  cell,
}: let
  inherit (inputs) nixpkgs;
  inherit (inputs.cells) std;
in {
  treefmt = std.nixago.treefmt {
    configData.formatter.go = {
      command = "gofmt";
      options = ["-w"];
      includes = ["*.go"];
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
    };
  };
}
