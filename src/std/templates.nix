{
  inputs,
  cell,
}: {
  rust = {
    path = ./templates/rust;
    description = "Sane Defaults for Nix-centric Rust Development";
  };
  minimal = {
    path = ./templates/minimal;
    description = "Get started with a minimal, documented Standard project";
  };
}
