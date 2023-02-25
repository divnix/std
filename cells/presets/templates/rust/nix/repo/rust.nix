{
  inputs,
  cell,
}: let
  inherit (inputs.fenix) packages;

  # change "stable" to "complete" for nightly rust
  rustPkgs = packages.stable;
  rustPkgs' =
    if rustPkgs ? rust-analyzer
    then rustPkgs
    else rustPkgs // { inherit (packages) rust-analyzer; };
in
  # export fenix toolchain as it's own package set
  builtins.removeAttrs rustPkgs' ["withComponents" "name" "type"]
