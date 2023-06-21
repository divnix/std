/*
This file holds configuration data for repo dotfiles.

Q: Why not just put the put the file there?

A: (1) dotfile proliferation
   (2) have all the things in one place / fromat
   (3) potentially share / re-use configuration data - keeping it in sync
*/
{
  inputs,
  cell,
}: {
  # Tool Homepage: https://editorconfig.org/
  editorconfig = {
    data = {
      root = true;

      "*" = {
        end_of_line = "lf";
        insert_final_newline = true;
        trim_trailing_whitespace = true;
        charset = "utf-8";
        indent_style = "space";
        indent_size = 2;
      };

      "*.{diff,patch}" = {
        end_of_line = "unset";
        insert_final_newline = "unset";
        trim_trailing_whitespace = "unset";
        indent_size = "unset";
      };

      "*.md" = {
        max_line_length = "off";
        trim_trailing_whitespace = false;
      };

      "{LICENSES/**,LICENSE}" = {
        end_of_line = "unset";
        insert_final_newline = "unset";
        trim_trailing_whitespace = "unset";
        charset = "unset";
        indent_style = "unset";
        indent_size = "unset";
      };
    };
  };

  # Tool Homepage: https://numtide.github.io/treefmt/
  treefmt = {
    packages = [
      inputs.nixpkgs.alejandra
      inputs.nixpkgs.nodePackages.prettier
      inputs.nixpkgs.nodePackages.prettier-plugin-toml
      inputs.nixpkgs.shfmt
    ];
    devshell.startup.prettier-plugin-toml = inputs.nixpkgs.lib.stringsWithDeps.noDepEntry ''
      export NODE_PATH=${inputs.nixpkgs.nodePackages.prettier-plugin-toml}/lib/node_modules:''${NODE_PATH-}
    '';
    data = {
      formatter = {
        nix = {
          command = "alejandra";
          includes = ["*.nix"];
        };
        prettier = {
          command = "prettier";
          options = ["--plugin" "prettier-plugin-toml" "--write"];
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
  };

  # Tool Homepage: https://github.com/evilmartians/lefthook
  lefthook = {
    data = {
      commit-msg = {
        commands = {
          conform = {
            # allow WIP, fixup!/squash! commits locally
            run = ''
              [[ "$(head -n 1 {1})" =~ ^WIP(:.*)?$|^wip(:.*)?$|fixup\!.*|squash\!.* ]] ||
              conform enforce --commit-msg-file {1}'';
            skip = ["merge" "rebase"];
          };
        };
      };
      pre-commit = {
        commands = {
          treefmt = {
            run = "treefmt --fail-on-change {staged_files}";
            skip = ["merge" "rebase"];
          };
        };
      };
    };
  };

  # Tool Hompeage: https://github.com/apps/settings
  # Install Setting App in your repo to enable it
  githubsettings = {
    data = {
      repository = {
        name = "CONFIGURE-ME";
        inherit (import (inputs.self + /flake.nix)) description;
        homepage = "CONFIGURE-ME";
        topics = "CONFIGURE-ME";
        default_branch = "main";
        allow_squash_merge = false;
        allow_merge_commit = false;
        allow_rebase_merge = true;
        delete_branch_on_merge = true;
        private = true;
        has_issues = false;
        has_projects = false;
        has_wiki = false;
        has_downloads = false;
      };
    };
  };

  # Tool Homepage: https://rust-lang.github.io/mdBook/
  mdbook = {
    # add preprocessor packages here
    packages = [
      inputs.nixpkgs.mdbook-linkcheck
    ];
    data = {
      # Configuration Reference: https://rust-lang.github.io/mdBook/format/configuration/index.html
      book = {
        language = "en";
        multilingual = false;
        title = "CONFIGURE-ME";
        src = "docs";
      };
      build.build-dir = "docs/build";
      preprocessor = {};
      output = {
        html = {};
        # Tool Homepage: https://github.com/Michael-F-Bryan/mdbook-linkcheck
        linkcheck = {};
      };
    };
    output = "book.toml";
    hook.mode = "copy"; # let CI pick it up outside of devshell
  };
}
