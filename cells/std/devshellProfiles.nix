{
  inputs,
  cell,
}: let
  std = cell.cli.default;
  nixpkgs = inputs.nixpkgs;
in {
  default = {config, ...}: {
    config = {
      commands = [
        {package = std;}
        {package = nixpkgs.adrgen;}
        {package = nixpkgs.mdbook;}
      ];
      devshell.startup.init-adrgen = nixpkgs.lib.stringsWithDeps.noDepEntry ''
        if [ ! -d "docs/architecture-decisions" ]; then
          ${nixpkgs.adrgen}/bin/adrgen init "docs/architecture-decisions"
        fi
      '';
      devshell.startup.init-mdbook = let
        config = {};
      in
        nixpkgs.lib.stringsWithDeps.noDepEntry ''
          if [ ! -f "book.toml" ]; then
          mkdir -p docs
          cat << EOF > book.toml
          [book]
          language = "en"
          multilingual = false
          src = "docs"
          title = "Documentation"

          [build]
          build-dir = "docs/book"

          EOF
          cat << EOF > docs/SUMMARY.md
          # Summary

          EOF
          fi
          if [ ! -f "docs/.gitignore" ]; then
          cat << EOF > docs/.gitignore
          # mdbook build
          book/**
          EOF
          fi

          if ! grep -qF 'book/' docs/.gitignore; then
          cat << EOF >> docs/.gitignore

          # mdbook build
          book/**
          EOF
          fi
        '';
    };
  };
}
