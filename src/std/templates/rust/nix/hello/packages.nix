{
  inputs,
  cell,
}: let
  inherit (inputs) std self cells;

  crane = inputs.crane.lib.overrideToolchain cells.repo.rust.toolchain;
in {
  # sane default for a binary package
  default = crane.buildPackage {
    src = std.incl self [
      "${self}/Cargo.lock"
      "${self}/Cargo.toml"
      "${self}/src"
    ];
  };
}
