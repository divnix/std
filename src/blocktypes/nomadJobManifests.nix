{
  nixpkgs,
  mkCommand,
}: let
  l = nixpkgs.lib // builtins;
  /*
  Use the `nomadJobsManifest` Blocktype for rendering job descriptions
  for the Nomad Cluster scheduler. Each named attribtute-set under the
  block contains a valid Nomad job description, written in Nix.

  Available actions:
    - render
    - deploy
    - explore
  */
  nomadJobManifests = name: {
    __functor = import ./__functor.nix;
    inherit name;
    type = "nomadJobManifests";

    actions = {
      system,
      fragment,
      fragmentRelPath,
      target,
    }: let
      fx = "${nixpkgs.legacyPackages.${system}.fx}/bin";
      nomad = "${nixpkgs.legacyPackages.${system}.nomad}/bin";
      jq = "${nixpkgs.legacyPackages.${system}.jq}/bin";
      job = baseNameOf fragmentRelPath;
      nixExpr = ''
        x: let
          job = builtins.mapAttrs (_: v: v // {meta = v.meta or {} // {rev = "\"$(git rev-parse --short HEAD)\"";};}) x.job;
        in
          builtins.toFile \"${job}.json\" (builtins.unsafeDiscardStringContext (builtins.toJSON {inherit job;}))
      '';
      layout = ''
        if test -z "$PRJ_ROOT"; then
          echo "PRJ_ROOT is not set. Action aborting."
          exit 1
        fi
        if test -z "$PRJ_DATA_DIR"; then
          echo "PRJ_DATA_DIR is not set. Action aborting."
          exit 1
        fi
        job_path="$PRJ_DATA_DIR/${dirOf fragmentRelPath}/${job}.json"

        # use Nomad bin in path if it exists, and only fallback on nixpkgs if it doesn't
        PATH="$PATH:${nomad}"
      '';
      render = ''
        if test -z "$PRJ_ROOT"; then
          echo "PRJ_ROOT is not set. Action aborting."
          exit 1
        fi

        echo "Rendering to $job_path..."

        # use `PRJ_ROOT` to capture dirty state
        if ! out="$(nix eval --no-allow-dirty --raw $PRJ_ROOT\#${fragment} --apply "${nixExpr}")"; then
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
      The `render` action will take this Nix job descrition, convert it to JSON,
      inject the git revision validate the manifest, after which it can be run or
      planned with the Nomad cli or the `deploy` action.
      */
      (mkCommand system {
        name = "render";
        description = "build the JSON job description";
        command =
          # bash
          ''
            set -e

            ${layout}

            ${render}
          '';
      })
      (mkCommand system {
        name = "deploy";
        description = "Deploy the job to Nomad";
        command =
          # bash
          ''
            set -e

            ${layout}

            PATH=$PATH:${jq}

            if ! [[ -h "$job_path" ]] \
              || [[ "$(jq -r '.job[].meta.rev' "$job_path")" != "$(git rev-parse --short HEAD)" ]]
            then ${render}
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
      })
      (mkCommand system {
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
      })
    ];
  };
in
  nomadJobManifests
