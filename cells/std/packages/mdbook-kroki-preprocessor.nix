{
  inputs,
  cell,
}:
with inputs.nixpkgs;
  rustPlatform.buildRustPackage {
    pname = "mdbook-kroki-preprocessor";
    version = "0.1.0";
    nativeBuildInputs = [pkg-config];
    buildInputs = [openssl];

    cargoLock = {
      lockFile = inputs.mdbook-kroki-preprocessor + "/Cargo.lock";
    };

    src = inputs.mdbook-kroki-preprocessor;

    meta = {
      description = "A mdbook preprocessor to render kroki-supported diagrams on the fly";
    };
  }
