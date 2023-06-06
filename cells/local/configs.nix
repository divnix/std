{
  inputs,
  scope,
}: let
  inherit (inputs) nixpkgs;
  inherit (inputs.cells) std presets;
  l = nixpkgs.lib // builtins;
in {
  cog = {
    output = "cog.toml";
    commands = [{package = nixpkgs.cocogitto;}];
    data = {
      tag_prefix = "v";
      branch_whitelist = ["main" "release/**"];
      ignore_merge_commits = true;
      pre_bump_hooks = [
        ''git switch -c "$(echo "release/{{version}}" | sed 's/\.[^.]*$//')" || git switch "$(echo "release/{{version}}" | sed 's/\.[^.]*$//')"''
        "echo {{version}} > ./VERSION"
      ];
      post_bump_hooks = [
        ''git push --set-upstream origin "$(echo "release/{{version}}" | sed 's/\.[^.]*$//')"''
        "git push origin v{{version}}"
        "cog -q changelog --at v{{version}}"
        "git switch main"
        ''git checkout "$(echo "release/{{version}}" | sed 's/\.[^.]*$//')" -- ./VERSION''
        ''git merge "$(echo "release/{{version}}" | sed 's/\.[^.]*$//')"''
        "git push"
        "echo {{version+minor-dev}} > ./VERSION"
        "git add VERSION"
      ];
      changelog = {
        path = "CHANGELOG.md";
        template = "remote";
        remote = "github.com";
        repository = "std";
        owner = "divnix";
      };
    };
  };
  treefmt = {
    data = {
      global.excludes = [
        "cells/presets/templates/**"
      ];
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

        go = {
          command = "gofmt";
          options = ["-w"];
          includes = ["*.go"];
        };
        prettier = {
          excludes = ["**.min.js"];
        };
      };
    };
    packages = [
      nixpkgs.alejandra
      nixpkgs.nodePackages.prettier
      nixpkgs.nodePackages.prettier-plugin-toml
      nixpkgs.shfmt
      nixpkgs.go
    ];
    devshell.startup.prettier-plugin-toml = l.stringsWithDeps.noDepEntry ''
      export NODE_PATH=${nixpkgs.nodePackages.prettier-plugin-toml}/lib/node_modules:$NODE_PATH
    '';
  };
  editorconfig = {
    hook.mode = "copy"; # already useful before entering the devshell
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

      "*.xcf" = {
        charset = "unset";
        end_of_line = "unset";
        insert_final_newline = "unset";
        trim_trailing_whitespace = "unset";
        indent_style = "unset";
        indent_size = "unset";
      };
      "{*.go,go.mod}" = {
        indent_style = "tab";
        indent_size = 4;
      };
    };
  };
  just = {
    data = {
      tasks = import ./tasks.nix;
    };
  };
  mdbook = {
    output = "docs/book.toml";
    data = {
      book = {
        language = "en";
        multilingual = false;
        title = "The Standard Documentation";
        src = ".";
      };
      build = {
        build-dir = "book";
      };
      preprocessor = {
        paisano-preprocessor = {
          before = ["links"];
          registry = "..#__std.init";
          multi = [
            {
              chapter = "Cell: lib";
              cell = "lib";
            }
            {
              chapter = "Cell: std";
              cell = "std";
            }
          ];
        };
      };
      output.html = {
        additional-js = ["theme/pagetoc.js"];
        additional-css = ["theme/pagetoc.css"];
      };
    };
    packages = [inputs.paisano-mdbook-preprocessor.packages.default];
    hook.mode = "copy"; # let CI pick it up outside of devshell
  };
  githubsettings = {
    data = let
      colors = {
        black = "#000000";
        blue = "#1565C0";
        lightBlue = "#64B5F6";
        green = "#4CAF50";
        grey = "#A6A6A6";
        lightGreen = "#81C784";
        gold = "#FDD835";
        orange = "#FB8C00";
        purple = "#AB47BC";
        red = "#F44336";
        yellow = "#FFEE58";
      };
      labels = {
        statuses = {
          abandoned = {
            name = ":running: Status: Abdandoned";
            description = "This issue has been abdandoned";
            color = colors.black;
          };
          accepted = {
            name = ":ok: Status: Accepted";
            description = "This issue has been accepted";
            color = colors.green;
          };
          blocked = {
            name = ":x: Status: Blocked";
            description = "This issue is in a blocking state";
            color = colors.red;
          };
          inProgress = {
            name = ":construction: Status: In Progress";
            description = "This issue is actively being worked on";
            color = colors.grey;
          };
          onHold = {
            name = ":golf: Status: On Hold";
            description = "This issue is not currently being worked on";
            color = colors.red;
          };
          reviewNeeded = {
            name = ":eyes: Status: Review Needed";
            description = "This issue is pending a review";
            color = colors.gold;
          };
        };
        types = {
          bug = {
            name = ":bug: Type: Bug";
            description = "This issue targets a bug";
            color = colors.red;
          };
          story = {
            name = ":scroll: Type: Story";
            description = "This issue targets a new feature through a story";
            color = colors.lightBlue;
          };
          maintenance = {
            name = ":wrench: Type: Maintenance";
            description = "This issue targets general maintenance";
            color = colors.orange;
          };
          question = {
            name = ":grey_question: Type: Question";
            description = "This issue contains a question";
            color = colors.purple;
          };
          security = {
            name = ":cop: Type: Security";
            description = "This issue targets a security vulnerability";
            color = colors.red;
          };
        };
        priorities = {
          critical = {
            name = ":boom: Priority: Critical";
            description = "This issue is prioritized as critical";
            color = colors.red;
          };
          high = {
            name = ":fire: Priority: High";
            description = "This issue is prioritized as high";
            color = colors.orange;
          };
          medium = {
            name = ":star2: Priority: Medium";
            description = "This issue is prioritized as medium";
            color = colors.yellow;
          };
          low = {
            name = ":low_brightness: Priority: Low";
            description = "This issue is prioritized as low";
            color = colors.green;
          };
        };
        effort = {
          "1" = {
            name = ":muscle: Effort: 1";
            description = "This issue is of low complexity or very well understood";
            color = colors.green;
          };
          "2" = {
            name = ":muscle: Effort: 3";
            description = "This issue is of medium complexity or only partly well understood";
            color = colors.yellow;
          };
          "5" = {
            name = ":muscle: Effort: 5";
            description = "This issue is of high complexity or just not yet well understood";
            color = colors.red;
          };
        };
      };

      l = builtins;
    in
      {
        labels =
          []
          ++ (l.attrValues labels.statuses)
          ++ (l.attrValues labels.types)
          ++ (l.attrValues labels.priorities)
          ++ (l.attrValues labels.effort);
      }
      // {
        repository = {
          name = "std";
          homepage = "https://std.divnix.com";
          description = "A DevOps framework for the SDLC with the power of Nix and Flakes. Good for keeping deadlines!";
          topics = "nix, nix-flakes, devops, sdlc";
          default_branch = "main";
          allow_squash_merge = true;
          allow_merge_commit = false;
          allow_rebase_merge = true;
          delete_branch_on_merge = true;
        };
        milestones = [
          {
            title = "Release v1";
            description = ":dart:";
            state = "open";
          }
        ];
      };
  };
}
