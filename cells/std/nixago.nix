{
  inputs,
  cell,
}:
builtins.mapAttrs (_: inputs.cells.lib.dev.mkNixago) {
  adrgen = import ./nixago/adrgen.nix {inherit inputs cell;};
  editorconfig = import ./nixago/editorconfig.nix {inherit inputs cell;};
  conform = import ./nixago/conform.nix {inherit inputs cell;};
  just = import ./nixago/just.nix {inherit inputs cell;};
  lefthook = import ./nixago/lefthook.nix {inherit inputs cell;};
  mdbook = import ./nixago/mdbook.nix {inherit inputs cell;};
  treefmt = import ./nixago/treefmt.nix {inherit inputs cell;};
}
