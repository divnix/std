{nixpkgs}: let
  l = nixpkgs.lib // builtins;
  /*
  Use the `nomadJobsManifest` Blocktype for rendering job descriptions for the Nomad Cluster scheduler
  where each attribute in the block is a description of a Nomad job. Each named attribtute-set under
  the block contains a valid Nomad job description, written in Nix.

  i.e: `nomadJobManifests.<job-name>.<valid-job-description>`.
  */
  functions = name: {
    inherit name;
    type = "nomadJobManifests";

    actions = {
      system,
      flake,
      fragment,
      fragmentRelPath,
    }: [
      /*
      The `render` action will take this Nix job descrition, convert it to JSON, inject the git revision
      validate the manifest, after which it can be run or planned with the Nomad cli or the `deploy` action.
      */
      {
        name = "render";
        description = "build the JSON job description";
        command = let
          nomad = "${nixpkgs.legacyPackages.${system}.nomad}/bin";
          nixExpr = ''
            x: let
              job = builtins.mapAttrs (_: v: v // {meta = v.meta or {} // {rev = "\"$(git rev-parse --short HEAD)\"";};}) x.job;
            in
              builtins.toFile \"$job.json\" (builtins.unsafeDiscardStringContext (builtins.toJSON {inherit job;}))
          '';
        in
          # bash
          ''
            set -e
            # act from the top-level
            REPO_DIR="$(git rev-parse --show-toplevel)"
            cd "$REPO_DIR"

            if ! git check-ignore jobs --quiet; then
              printf "%s\n" "# Nomad Jobs" "jobs" >> .gitignore
              git add .gitignore
              echo >&2 "Please commit staged gitignore changes before continuing"
              # Don't exit here, as dirty check below will fail and report for us
            fi

            # use Nomad bin in path if it exists, and only fallback on nixpkgs if it doesn't
            PATH="$PATH:${nomad}"

            job_path="jobs/${baseNameOf fragmentRelPath}.json"
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
      }
      {
        name = "deploy";
        description = "Deploy the job to Nomad";
        command =
          # bash
          ''
            set -e
            # act from the top-level
            REPO_DIR="$(git rev-parse --show-toplevel)"
            cd "$REPO_DIR"

            job_path="jobs/${baseNameOf fragmentRelPath}.json"

            if ! [[ -h "$job_path" ]]; then
              std "//${fragmentRelPath}:render"
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
        command = let
          fx = "${nixpkgs.legacyPackages.${system}.fx}/bin";
        in
          # bash
          ''
            set -e
            # act from the top-level
            REPO_DIR="$(git rev-parse --show-toplevel)"
            cd "$REPO_DIR"

            job_path="jobs/${baseNameOf fragmentRelPath}.json"

            if ! [[ -h "$job_path" ]]; then
              std "//${fragmentRelPath}:render"
            fi

            PATH=$PATH:${fx}

            fx "$job_path"
          '';
      }
    ];
  };
in
  functions
