let
  inherit (inputs) nixpkgs;
  inherit (inputs.nixpkgs) lib;
in {
  packages = [
    nixpkgs.alejandra
    nixpkgs.nodePackages.prettier
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
        options = ["--write"];
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
