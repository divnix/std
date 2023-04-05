{
  inputs,
  cell,
}: {
  adrgen = inputs.nixpkgs.callPackage ./packages/adrgen.nix {};
  mdbook = inputs.nixpkgs.mdbook;
  mdbook-kroki-preprocessor = inputs.nixpkgs.callPackage ./packages/mdbook-kroki-preprocessor.nix {};
  mdbook-paisano-preprocessor = inputs.paisano-mdbook-preprocessor.packages.default;
}
