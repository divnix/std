{
  rustPlatform,
  pkg-config,
  lib,
  stdenv,
  darwin,
  openssl,
  fetchFromGitHub,
}:
rustPlatform.buildRustPackage rec {
  pname = "mdbook-kroki-preprocessor";
  version = "0.1.2";
  nativeBuildInputs = [pkg-config];
  buildInputs = [openssl] ++ lib.optional stdenv.isDarwin darwin.apple_sdk.frameworks.Security;

  cargoLock = {
    lockFile = src + "/Cargo.lock";
  };

  src = fetchFromGitHub {
    owner = "JoelCourtney";
    repo = "mdbook-kroki-preprocessor";
    rev = "v${version}";
    sha256 = "sha256-1TJuUzfyMycWlOQH67LR63/ll2GDZz25I3JfScy/Jnw=";
  };

  meta = {
    description = "A mdbook preprocessor to render kroki-supported diagrams on the fly";
  };
}
