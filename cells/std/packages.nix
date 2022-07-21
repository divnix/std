{
  inputs,
  cell,
}: {
  adrgen = inputs.nixpkgs.adrgen;
  mdbook = inputs.nixpkgs.mdbook;
  mdbook-kroki-preprocessor = import ./packages/mdbook-kroki-preprocessor.nix {inherit inputs cell;};
}
