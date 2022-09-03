{
  inputs,
  cell,
}: let
  inherit (inputs) nixpkgs;
  l = nixpkgs.lib // builtins;
in
  l.mapAttrs (_: cell.lib.mkNixago) {
    treefmt = {
      configData = import ./nixago/treefmt.nix;
      output = "treefmt.toml";
      format = "toml";
      packages = [
        nixpkgs.alejandra
        nixpkgs.nodePackages.prettier
        nixpkgs.nodePackages.prettier-plugin-toml
        nixpkgs.shfmt
        nixpkgs.treefmt
      ];
      commands = [{package = nixpkgs.treefmt;}];
      devshell.startup.prettier-plugin-toml = l.stringsWithDeps.noDepEntry ''
        export NODE_PATH=${nixpkgs.nodePackages.prettier-plugin-toml}/lib/node_modules:$NODE_PATH
      '';
    };
    editorconfig = {
      configData = import ./nixago/editorconfig.nix;
      output = ".editorconfig";
      format = "ini";
      hook.mode = "copy"; # already useful before entering the devshell
      packages = [nixpkgs.editorconfig-checker];
    };
    conform = {
      configData = import ./nixago/conform.nix;
      format = "yaml";
      output = ".conform.yaml";
      packages = [nixpkgs.conform];
      apply = d: {
        policies =
          []
          ++ (l.optional (d ? commit) {
            type = "commit";
            spec =
              d.commit
              // l.optionalAttrs (d ? cells) {
                conventional =
                  d.commit.conventional
                  // {
                    scopes =
                      d.commit.conventional.scopes
                      ++ (l.subtractLists l.systems.doubles.all (l.attrNames d.cells));
                  };
              };
          })
          ++ (l.optional (d ? license) {
            type = "license";
            spec = d.license;
          });
      };
    };
    just = {
      configData = {};
      apply = d: {data = d;}; # CUE expects structure to be wrapped with "data"
      format = "text";
      output = ".justfile";
      packages = [nixpkgs.just];
      hook = {
        mode = "copy";
      };
      engine = inputs.nixago.engines.cue {
        files = [./nixago/just.cue];
        flags = {
          expression = "rendered";
          out = "text";
        };
        postHook = ''
          ${inputs.nixpkgs.just}/bin/just --unstable --fmt -f $out
        '';
      };
    };
    lefthook = {
      configData = import ./nixago/lefthook.nix;
      format = "yaml";
      output = "lefthook.yml";
      packages = [nixpkgs.lefthook];
      hook.extra = d: let
        # Add an extra hook for adding required stages whenever the file changes
        skip_attrs = [
          "colors"
          "extends"
          "skip_output"
          "source_dir"
          "source_dir_local"
        ];
        stages = l.attrNames (l.removeAttrs d skip_attrs);
        stagesStr = l.concatStringsSep " " stages;
      in ''
        # Install configured hooks
        for stage in ${stagesStr}; do
          ${nixpkgs.lefthook}/bin/lefthook add -f "$stage"
        done
      '';
    };
    mdbook = {
      configData = import ./nixago/mdbook.nix;
      output = "book.toml";
      format = "toml";
      hook.mode = "copy"; # let CI pick it up outside of devshell
      hook.extra = let
        sentinel = "nixago-auto-created: mdbook-build-folder";
        file = "docs/.gitignore";
        str = ''
          # ${sentinel}
          book/**
        '';
      in ''
        # Configure gitignore
        create() {
          echo -n "${str}" > "${file}"
        }
        append() {
          echo -en "\n${str}" >> "${file}"
        }
        if ! test -f "${file}"; then
          create
        elif ! grep -qF "${sentinel}" "${file}"; then
          append
        fi
      '';
      packages = [cell.packages.mdbook-kroki-preprocessor];
      commands = [{package = nixpkgs.mdbook;}];
    };
    adrgen = {
      configData = import ./nixago/adrgen.nix;
      output = "adrgen.config.yml";
      format = "yaml";
      commands = [{package = cell.packages.adrgen;}];
    };
  }
