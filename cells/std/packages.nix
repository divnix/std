{
  inputs,
  cell,
}: {
  adrgen = inputs.nixpkgs.callPackage ./packages/adrgen.nix {};
  mdbook = inputs.nixpkgs.mdbook;
  mdbook-kroki-preprocessor = import ./packages/mdbook-kroki-preprocessor.nix {inherit inputs cell;};
}
