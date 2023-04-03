{
  inputs,
  cell,
}: let
  inherit (inputs) fenix;

  # you may change "default" to any of "[minimal|default|complete|latest]" for variants
  # see upstream fenix documentation for details
  rustPkgs = builtins.removeAttrs fenix.packages.default ["withComponents" "name" "type"];
in
  # export fenix toolchain as it's own package set
  if rustPkgs ? rust-analyzer
  then rustPkgs
  else
    rustPkgs
    // {
      # add rust-analyzer from nightly, if not present
      inherit (fenix.packages) rust-analyzer;
      toolchain = fenix.packages.combine [
        (builtins.attrValues rustPkgs)
        fenix.packages.rust-analyzer
      ];
    }
