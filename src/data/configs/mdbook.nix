let
  inherit (inputs) nixpkgs;
  inherit (inputs.mdbook-paisano-preprocessor.app.package) mdbook-paisano-preprocessor;
in {
  hook.mode = "copy"; # let CI pick it up outside of devshell
  packages = [
    nixpkgs.alejandra
    nixpkgs.nodePackages.prettier
    nixpkgs.shfmt
    mdbook-paisano-preprocessor
  ];

  data = {
    book = {
      language = "en";
      multilingual = false;
      src = "docs";
      title = "Documentation";
    };
    build = {
      build-dir = "docs/book";
    };
    preprocessor.paisano-preprocessor = {
      before = ["links"];
      registry = ".#__std.init";
    };
  };
}
