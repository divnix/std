{
  nixpkgs,
  root,
}:
/*
Use the arion for arionCompose Jobs - https://docs.hercules-ci.com/arion/

Available actions:
  - up
  - ps
  - stop
  - rm
  - config
  - arion
*/
let
  inherit (root) mkCommand;
in
  name: {
    inherit name;
    type = "arion";
    actions = {
      currentSystem,
      fragment,
      fragmentRelPath,
      target,
    }: let
      pkgs = nixpkgs.legacyPackages.${currentSystem};
      cmd = "${pkgs.arion}/bin/arion --prebuilt-file ${target.config.out.dockerComposeYaml}";
    in [
      (mkCommand currentSystem "up" "arion up" ''${cmd} up "$@" '' {})
      (mkCommand currentSystem "ps" "exec this arion task to ps" ''${cmd} ps "$@" '' {})
      (mkCommand currentSystem "stop" "arion stop" ''${cmd} stop "$@" '' {})
      (mkCommand currentSystem "rm" "arion rm" ''${cmd} rm "$@" '' {})
      (mkCommand currentSystem "config" "check the docker-compose yaml file" ''${cmd} config "$@" '' {})
      (mkCommand currentSystem "arion" "pass any command to arion" ''${cmd} "$@" '' {})
    ];
  }
