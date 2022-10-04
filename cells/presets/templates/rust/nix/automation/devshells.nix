{
  inputs,
  cell,
}: let
  inherit (inputs.std) std lib;
  inherit (inputs) nixpkgs fenix;
  inherit (inputs.cells) rust hello;

  l = nixpkgs.lib // builtins;
  dev = lib.dev.mkShell {
    packages = [
      nixpkgs.pkg-config
    ];
    language.rust = {
      packageSet = rust.packages.toolchain;
      enableDefaultToolchain = false;
    };
    env = [
      {
        name = "RUST_SRC_PATH";
        value = "${rust.packages.rust-src}/lib/rustlib/src/rust/library";
      }
      {
        name = "PKG_CONFIG_PATH";
        value = l.makeSearchPath "lib/pkgconfig" hello.packages.default.buildInputs;
      }
    ];
    imports = [
      "${inputs.std.inputs.devshell}/extra/language/rust.nix"
    ];

    commands = let
      rustCmds =
        l.mapAttrs' (name: package: {
          inherit name;
          value = {
            inherit package name;

            category = "rust dev";
            # fenix doesn't include package descriptions, so pull those out of their equivalents in nixpkgs
            help = nixpkgs.${name}.meta.description;
          };
        }) {
          inherit
            (rust.packages)
            rustc
            cargo
            clippy
            rustfmt
            rust-analyzer
            ;
        };
    in
      [
        {
          package = nixpkgs.treefmt;
          category = "repo tools";
        }
        {
          package = nixpkgs.alejandra;
          category = "repo tools";
        }
        {
          package = std.cli.default;
          category = "std";
        }
      ]
      ++ l.attrValues rustCmds;
  };
in {
  inherit dev;
  default = dev;
}
