{
  inputs,
  cell,
}: let
  /*
  I usually just find it very handy to alias all things library onto `l`...
  The distinction between `builtins` and `nixpkgs.lib` has little practical
  relevance, in most scenarios.
  */
  l = nixpkgs.lib // builtins;

  /*
  It is good practice to in-scope:
  - inputs by *name*
  - other Cells by their *Cell names*
  - the local Cell Blocks by their *Block names*.

  However, for `std`, we make an exeption and in-scope, despite being an
  input, it's primary Cell with the same name.
  */
  inherit (inputs) nixpkgs;
  inherit (inputs.std) std;
  inherit (cell) nixago;
in
  # we use Standard's mkShell wrapper for its Nixago integration
  l.mapAttrs (_: std.lib.mkShell) {
    default = {...}: {
      name = "My Devshell";
      # This `nixago` option is a courtesy of the `std` horizontal
      # integration between Devshell and Nixago
      nixago = [
        # off-the-shelve from `std`
        (std.nixago.conform {configData = {inherit (inputs) cells;};})
        std.nixago.lefthook
        std.nixago.adrgen
        # modified from the local Cell
        nixago.treefmt
        nixago.editorconfig
        nixago.mdbook
      ];
      # Devshell handily represents `commands` as part of
      # its Message Of The Day (MOTD) or the built-in `menu` command.
      commands = [
        {
          package = nixpkgs.reuse;
          category = "legal";
          /*
          For display, reuse already has both a `pname` & `meta.description`.
          Hence, we don't need to inline these - they are autodetected:

          name = "reuse";
          description = "Reuse is a tool to manage a project's LICENCES";
          */
        }
      ];
      # Always import the `std` default devshellProfile to also install
      # the `std` CLI/TUI into your Devshell.
      imports = [std.devshellProfiles.default];
    };
  }
