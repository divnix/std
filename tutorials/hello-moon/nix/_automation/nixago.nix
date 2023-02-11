{
  inputs,
  cell,
}: let
  inherit (inputs) nixpkgs;
  inherit (inputs.std) lib;
  /*
  While these are strictly specializations of the available
  Nixago Pebbles at `lib.cfg.*`, it would be entirely
  possible to define a completely new pebble inline
  */
in {
  /*
  treefmt: https://github.com/numtide/treefmt
  */
  treefmt = lib.cfg.treefmt {
    # we use the data attribute to modify the
    # target data structure via a simple data overlay
    # (`divnix/data-merge` / `std.dmerge`) mechanism.
    data.formatter.go = {
      command = "gofmt";
      options = ["-w"];
      includes = ["*.go"];
    };
    # for the `std.lib.dev.mkShell` integration with nixago,
    # we also hint which packages should be made available
    # in the environment for this "Nixago Pebble"
    packages = [nixpkgs.go];
  };

  /*
  editorconfig: https://editorconfig.org/
  */
  editorconfig = lib.cfg.editorconfig {
    data = {
      # the actual target data structure depends on the
      # Nixago Pebble, and ultimately, on the tool to configure
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

  /*
  mdbook: https://rust-lang.github.io/mdBook
  */
  mdbook = lib.cfg.mdbook {
    data = {
      book.title = "The Standard Book";
    };
  };
}
