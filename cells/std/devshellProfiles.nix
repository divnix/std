{
  inputs,
  cell,
}: let
  l = nixpkgs.lib // builtins;
  nixpkgs = inputs.nixpkgs;
in {
  default = {config, ...}: let
    cfg = config.std;
  in {
    options.std = {
      adr.enable = (l.mkEnableOption "Enable ADR nudging") // {default = true;};
      docs.enable = (l.mkEnableOption "Enable Docs nudging") // {default = true;};
    };
    config = {
      motd = ''

        {202}{bold}🔨 Welcome to ${config.name} 🔨{reset}

        {italic}To autocomplete 'std' in bash, zsh, oil: {202}source <(std _carapace){reset}
        {italic}More shells: https://rsteube.github.io/carapace/carapace/gen/hiddenSubcommand.html{reset}

        $(type -p menu &>/dev/null && menu)
      '';
      packages = l.optionals (cfg.docs.enable && nixpkgs.stdenv.isLinux) [cell.packages.mdbook-kroki-preprocessor];
      commands =
        [
          {package = cell.cli.default;}
        ]
        ++ l.optionals cfg.adr.enable [
          {package = cell.packages.adrgen;}
        ]
        ++ l.optionals cfg.docs.enable [
          {package = cell.packages.mdbook;}
        ];
      devshell.startup.init-adrgen = l.mkIf cfg.adr.enable (l.stringsWithDeps.noDepEntry ''
        if [ ! -d "docs/architecture-decisions" ]; then
          ${l.getExe cell.packages.adrgen} init "docs/architecture-decisions"
        fi
      '');
      devshell.startup.init-mdbook =
        l.mkIf (cfg.docs.enable && nixpkgs.stdenv.isLinux)
        (l.stringsWithDeps.noDepEntry ''
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

          [preprocessor.kroki-preprocessor]
          command = "${l.getExe cell.packages.mdbook-kroki-preprocessor}"

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
        '');
    };
  };
}
