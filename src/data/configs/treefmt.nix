let
  inherit (inputs) nixpkgs;
  inherit (inputs.nixpkgs) nodePackages;
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
        command = "alejandra";
        includes = ["*.nix"];
      };
      prettier = {
        command = "prettier";
        options = ["--plugin" "${nodePackages.prettier-plugin-toml}/lib/node_modules/prettier-plugin-toml/lib/api.js" "--write"];
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
        command = "shfmt";
        options = ["-i" "2" "-s" "-w"];
        includes = ["*.sh"];
      };
    };
  };
}
