{
  inputs,
  cell,
}: let
  l = nixpkgs.lib // builtins;
  std = cell.cli.default;
  nixpkgs = inputs.nixpkgs;
  kroki-preprocessor = inputs.kroki-preprocessor.preprocessor.apps.preprocessor;
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
      packages = l.optionals (cfg.docs.enable && nixpkgs.stdenv.isLinux) [kroki-preprocessor];
      commands =
        [
          {package = std;}
        ]
        ++ l.optionals cfg.adr.enable [
          {package = nixpkgs.adrgen;}
        ]
        ++ l.optionals cfg.docs.enable [
          {package = nixpkgs.mdbook;}
        ];
      devshell.startup.init-adrgen = l.mkIf cfg.adr.enable (l.stringsWithDeps.noDepEntry ''
        if [ ! -d "docs/architecture-decisions" ]; then
          ${nixpkgs.adrgen}/bin/adrgen init "docs/architecture-decisions"
        fi
      '');
      devshell.startup.init-mdbook = l.mkIf (cfg.docs.enable && nixpkgs.stdenv.isLinux)
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
        command = "${kroki-preprocessor}/bin/mdbook-kroki-preprocessor"

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
  checks = {...}: {
    commands = [
      {
        name = "clade-data";
        command = "cat $(std //std/data/example:write)";
      }
      {
        name = "clade-devshells";
        command = "std //std/devshell/default:enter -- echo OK";
      }
      {
        name = "clade-runnables";
        command = "std //std/cli/default:run -- std OK";
      }
    ];
  };
}
