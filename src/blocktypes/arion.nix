{
  nixpkgs,
  mkCommand,
}: let
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
      fragment,
      fragmentRelPath,
      target,
    }: let
      cmd = "arion --prebuilt-file ${target.config.out.dockerComposeYaml}";
    in [
      (mkCommand system "arion" {
        name = "up";
        description = "arion up";
        command = ''
          ${cmd} up "$@"
        '';
      })
      (mkCommand system "arion" {
        name = "ps";
        description = "exec this arion task to ps";
        command = ''
          ${cmd} ps "$@"
        '';
      })
      (mkCommand system "arion" {
        name = "stop";
        description = "arion stop";
        command = ''
          ${cmd} stop "$@"
        '';
      })
      (mkCommand system "arion" {
        name = "rm";
        description = "arion rm";
        command = ''
          ${cmd} rm "$@"
        '';
      })
      (mkCommand system "arion" {
        name = "config";
        description = "check the docker-compose yaml file";
        command = ''
          ${cmd} config "$@"
        '';
      })
      (mkCommand system "arion" {
        name = "arion";
        description = "pass any command to arion";
        command = ''
          ${cmd} "$@"
        '';
      })
    ];
  };
in
  arion
