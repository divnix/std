{nixpkgs}: let
  l = nixpkgs.lib // builtins;
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
  arion = name: {
    inherit name;
    type = "arion";
    actions = {
      system,
      flake,
      fragment,
      fragmentRelPath,
      target,
    }: let
      cmd = "arion --prebuilt-file $(nix build ${flake}#${fragment}.config.out.dockerComposeYaml --print-out-paths)";
    in [
      {
        name = "up";
        description = "arion up";
        command = ''
          ${cmd} up "$@"
        '';
      }
      {
        name = "ps";
        description = "exec this arion task to ps";
        command = ''
          ${cmd} ps "$@"
        '';
      }
      {
        name = "stop";
        description = "arion stop";
        command = ''
          ${cmd} stop "$@"
        '';
      }
      {
        name = "rm";
        description = "arion rm";
        command = ''
          ${cmd} rm "$@"
        '';
      }
      {
        name = "config";
        description = "check the docker-compose yaml file";
        command = ''
          ${cmd} config "$@"
        '';
      }
      {
        name = "arion";
        description = "pass any command to arion";
        command = ''
          ${cmd} "$@"
        '';
      }
    ];
  };
in
  arion
