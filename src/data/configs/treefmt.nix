{prettier-plugin-toml}: {
  formatter = {
    nix = {
      command = "alejandra";
      includes = ["*.nix"];
    };
    prettier = {
      command = "prettier";
      options = ["--plugin" "${prettier-plugin-toml}/lib/node_modules/prettier-plugin-toml/lib/api.js" "--write"];
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
}
