{
  nixpkgs,
  root,
  super,
}:
/*
Use the `nomad` Block Type for rendering job descriptions
for the Nomad Cluster scheduler. Each named attribtute-set under the
block contains a valid Nomad job description, written in Nix.

Available actions:
  - render
  - deploy
  - explore
*/
let
  inherit (root) mkCommand;
  inherit (super) addSelectorFunctor askUserToProceedSnippet;
in
  name: {
    __functor = addSelectorFunctor;
    inherit name;
    type = "nomadJobManifests";

    actions = {
      currentSystem,
      fragment,
      fragmentRelPath,
      target,
      inputs,
    }: let
      inherit (nixpkgs) lib;
      pkgs = inputs.nixpkgs.${currentSystem};

      job_name = baseNameOf fragmentRelPath;
      job_path = "${dirOf fragmentRelPath}/${job_name}.json";

      jobWithGitRevision = target: let
        checkedRev = inputs.std.std.errors.bailOnDirty ''
          Will not render jobs from a dirty tree.
          Otherwise we cannot keep good track of deployment history.''
        inputs.self.rev;
        job = builtins.mapAttrs (_: v: lib.recursiveUpdate v {meta.rev = checkedRev;}) target.job;
      in
        builtins.toFile "${job_name}.json" (builtins.unsafeDiscardStringContext (builtins.toJSON {inherit job;}));
      render = ''
        declare job_path="$PRJ_DATA_HOME/${job_path}"
        _render() {
          echo "Rendering to $job_path..."
          rm -rf "$job_path"
          ln -sf "${jobWithGitRevision target}" "$job_path"
          if status=$(nomad validate "$job_path"); then
            echo "$status for $job_path"
          fi
        }
        render() {
          local mode="$1"
          if [[ "$mode" == "always" ]]
          then
            _render
          elif [[ "$mode" == "current-revision" ]] \
            && [[ "$(jq -r '.job[].meta.rev' "$job_path")" != "$(git rev-parse --short HEAD)" ]]
          then
            _render
          elif [[ "$mode" == "if-not-exists" ]] && [[ ! -h "$job_path" ]]
          then
            _render
          fi
        }
      '';
    in [
      /*
      The `render` action will take this Nix job descrition, convert it to JSON,
      inject the git revision validate the manifest, after which it can be run or
      planned with the Nomad cli or the `deploy` action.
      */
      (mkCommand currentSystem "render" "build the JSON job description" [pkgs.nomad] ''
        ${render}
        render always
      '' {})
      (mkCommand currentSystem "deploy" "Deploy the job to Nomad" [pkgs.nomad pkgs.jq] ''
        ${render}
        render if-not-exists
        render current-revision
        if ! plan_results=$(nomad plan -force-color "$job_path"); then
          echo "$plan_results"
          run() { echo "$plan_results" | grep 'nomad job run -check-index'; }
          ${askUserToProceedSnippet "deploy" "run"}
        else
          echo "Job hasn't changed since last deployment, nothing to deploy"
        fi
      '' {})
      (mkCommand currentSystem "explore" "interactively explore the Job defintion" [pkgs.nomad pkgs.fx] ''
        ${render}
        render always
        fx "$job_path"
      '' {})
    ];
  }
