{
  inputs,
  cell,
}: {
  adrgen = import ./cfg/adrgen.nix {inherit inputs cell;};
  editorconfig = import ./cfg/editorconfig.nix {inherit inputs cell;};
  conform = import ./cfg/conform.nix {inherit inputs cell;};
  just = import ./cfg/just.nix {inherit inputs cell;};
  lefthook = import ./cfg/lefthook.nix {inherit inputs cell;};
  mdbook = import ./cfg/mdbook.nix {inherit inputs cell;};
  treefmt = import ./cfg/treefmt.nix {inherit inputs cell;};
  githubsettings = import ./cfg/githubsettings.nix {inherit inputs cell;};
}
