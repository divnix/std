let
  inherit (inputs) nixpkgs;
  inherit (inputs.nixpkgs) lib;
in {
  packages = [
    nixpkgs.alejandra
    nixpkgs.nodePackages.prettier
    nixpkgs.nodePackages.prettier-plugin-toml
    nixpkgs.shfmt
  ];

  data = {
    formatter = {
      nix = {
        command = lib.getExe nixpkgs.alejandra;
        includes = ["*.nix"];
      };
      prettier = {
        command = lib.getExe nixpkgs.nodePackages.prettier;
        options = ["--plugin" "${nixpkgs.nodePackages.prettier-plugin-toml}/lib/node_modules/prettier-plugin-toml/lib/index.js" "--write"];
        includes = [
          "*.css"
          "*.html"
          "*.js"
          "*.json"
          "*.jsx"
          "*.md"
          "*.mdx"
          "*.scss"
          "*.ts"
          "*.yaml"
          "*.toml"
        ];
      };
      shell = {
        command = lib.getExe nixpkgs.shfmt;
        options = ["-i" "2" "-s" "-w"];
        includes = ["*.sh"];
      };
    };
  };
}
