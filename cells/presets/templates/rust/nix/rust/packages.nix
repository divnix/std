{
  inputs,
  cell,
}: let
  inherit (inputs.fenix) packages;
in
  # export fenix toolchain as it's own package set
  # change "stable" to "latest" for nightly rust
  builtins.removeAttrs (packages.stable // {inherit (packages) rust-analyzer;}) ["withComponents"]
