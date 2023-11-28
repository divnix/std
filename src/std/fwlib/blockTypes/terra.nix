{
  root,
  super,
}:
/*
Use the Terra Blocktype for terraform configurations managed by terranix.

Important! You need to specify the state repo on the blocktype, e.g.:

[
  (terra "infra" "git@github.com:myorg/myrepo.git")
]

Available actions:
  - init
  - plan
  - apply
  - state
  - refresh
  - destroy
*/
let
  inherit (root) mkCommand;
  inherit (super) addSelectorFunctor;
in
  name: repo: {
    inherit name;
    __functor = self: selectors: self // selectors;
    type = "terra";
    actions = {
      currentSystem,
      fragment,
      fragmentRelPath,
      target,
      inputs,
    }: let
      inherit (inputs) terranix;
      pkgs = inputs.nixpkgs.${currentSystem};

      repoFolder = with pkgs.lib;
        concatStringsSep "/" (["./nix"] ++ (init (splitString "/" fragmentRelPath)));

      git = {
        inherit repo;
        # repo = "git@github.com:myorg/myrepo.git";
        ref = "main";
        state = fragmentRelPath + "/state.json";
      };

      terraEval = import (terranix + /core/default.nix);
      terraformConfiguration = builtins.toFile "config.tf.json" (builtins.toJSON
        (terraEval {
          inherit pkgs; # only effectively required for `pkgs.lib`
          terranix_config = {
            _file = fragmentRelPath;
            imports = [target];
          };
          strip_nulls = true;
        })
        .config);

      setup = ''
        export TF_IN_AUTOMATION=1
        # export TF_INPUT=0
        export TF_DATA_DIR="$PRJ_DATA_HOME/${fragmentRelPath}"
        export TF_PLUGIN_CACHE_DIR="$PRJ_CACHE_HOME/tf-plugin-cache"
        mkdir -p "$TF_DATA_DIR"
        mkdir -p "$TF_PLUGIN_CACHE_DIR"
        dir="$PRJ_ROOT/${repoFolder}/.tf"
        mkdir -p "$PRJ_ROOT/${repoFolder}/.tf"
        cat << MESSAGE > "$PRJ_ROOT/${repoFolder}/.tf/readme.md"
        This is a tf staging area.
        It is motivated by the terraform CLI requiring to be executed in a staging area.
        MESSAGE

        if [[ -e "$dir/config.tf.json" ]]; then rm -f "$dir/config.tf.json"; fi
        jq '.' ${terraformConfiguration} > "$dir/config.tf.json"
      '';

      wrap = cmd: ''
        ${setup}
        terraform-backend-git git \
           --dir "$dir" \
           --repository ${git.repo} \
           --ref ${git.ref} \
           --state ${git.state} \
           terraform ${cmd} "$@";
      '';
    in [
      (mkCommand currentSystem "init" "tf init" [pkgs.jq pkgs.terraform pkgs.terraform-backend-git] (wrap "init") {})
      (mkCommand currentSystem "plan" "tf plan" [pkgs.jq pkgs.terraform pkgs.terraform-backend-git] (wrap "plan") {})
      (mkCommand currentSystem "apply" "tf apply" [pkgs.jq pkgs.terraform pkgs.terraform-backend-git] (wrap "apply") {})
      (mkCommand currentSystem "state" "tf state" [pkgs.jq pkgs.terraform pkgs.terraform-backend-git] (wrap "state") {})
      (mkCommand currentSystem "refresh" "tf refresh" [pkgs.jq pkgs.terraform pkgs.terraform-backend-git] (wrap "refresh") {})
      (mkCommand currentSystem "destroy" "tf destroy" [pkgs.jq pkgs.terraform pkgs.terraform-backend-git] (wrap "destroy") {})
    ];
  }
