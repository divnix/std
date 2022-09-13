{nixpkgs}: let
  l = nixpkgs.lib // builtins;
  /*
  Use the `nomadJobsManifest` Blocktype for rendering job descriptions for the Nomad Cluster scheduler.
  Each named attribtute-set under the block contains a valid Nomad job description, written in Nix.

  i.e: `nomadJobManifests.<job-name>.<valid-job-description>`.

  Available actions:
    - render
    - deploy
    - explore
  */
  functions = name: {
    inherit name;
    type = "nomadJobManifests";

    actions = {
      system,
      flake,
      fragment,
      fragmentRelPath,
    }: let
      fx = "${nixpkgs.legacyPackages.${system}.fx}/bin";
      nomad = "${nixpkgs.legacyPackages.${system}.nomad}/bin";
      nixExpr = ''
        x: let
          job = builtins.mapAttrs (_: v: v // {meta = v.meta or {} // {rev = "\"$(git rev-parse --short HEAD)\"";};}) x.job;
        in
          builtins.toFile \"$job.json\" (builtins.unsafeDiscardStringContext (builtins.toJSON {inherit job;}))
      '';
      layout = ''
        std_layout_dir=$PRJ_ROOT/.std
        job_path="$std_layout_dir/${dirOf fragmentRelPath}/${baseNameOf fragmentRelPath}.json"

        # use Nomad bin in path if it exists, and only fallback on nixpkgs if it doesn't
        PATH="$PATH:${nomad}"
      '';
      render = ''
        echo "Rendering to $job_path..."

        # use `.` instead of ${flake} to capture dirty state
        if ! out="$(nix eval --no-allow-dirty --raw .\#${fragment} --apply "${nixExpr}")"; then
          >&2 echo "error: Will not render jobs from a dirty tree, otherwise we cannot keep good track of deployment history."
          exit 1
        fi

        nix build "$out" --out-link "$job_path" 2>/dev/null

        if status=$(nomad validate "$job_path"); then
          echo "$status for $job_path"
        fi
      '';
    in [
      /*
      The `render` action will take this Nix job descrition, convert it to JSON, inject the git revision
      validate the manifest, after which it can be run or planned with the Nomad cli or the `deploy` action.
      */
      {
        name = "render";
        description = "build the JSON job description";
        command =
          # bash
          ''
            set -e

            ${layout}

            ${render}
          '';
      }
      {
        name = "deploy";
        description = "Deploy the job to Nomad";
        command =
          # bash
          ''
            set -e

            ${layout}

            if ! [[ -h "$job_path" ]]; then
            ${render}
            fi

            if ! plan_results=$(nomad plan -force-color "$job_path"); then
              echo "$plan_results"

              cmd="$(echo "$plan_results" | grep 'nomad job run -check-index')"

              # prompt user interactiely except in CI
              if ! [[ -v CI ]]; then
                read -rp "Deploy this job? (y/N)" deploy

                case "$deploy" in
                [Yy])
                  eval "$cmd"
                  ;;
                *)
                  echo "Exiting without deploying"
                  ;;
                esac
              else
                eval "$cmd"
              fi
            else
              echo "Job hasn't changed since last deployment, nothing to deploy"
            fi
          '';
      }
      {
        name = "explore";
        description = "interactively explore the Job defintion";
        command =
          # bash
          ''
            set -e

            ${layout}

            if ! [[ -h "$job_path" ]]; then
            ${render}
            fi

            PATH=$PATH:${fx}

            fx "$job_path"
          '';
      }
    ];
  };
in
  functions
