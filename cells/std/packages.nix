{
  mdbook = inputs.nixpkgs.mdbook;
  mdbook-paisano-preprocessor = inputs.paisano-mdbook-preprocessor.packages.default;
  adrgen = inputs.nixpkgs.callPackage scope.pkgFun.adrgen {};
  mdbook-kroki-preprocessor = inputs.nixpkgs.callPackage scope.pkgFun.mdbook-kroki-preprocessor {};
}
