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
      currentSystem,
      fragment,
      fragmentRelPath,
      target,
    }: let
      pkgs = nixpkgs.legacyPackages.${currentSystem};
      cmd = "${pkgs.arion}/bin/arion --prebuilt-file ${target.config.out.dockerComposeYaml}";
    in [
      (mkCommand currentSystem {
        name = "up";
        description = "arion up";
        command = ''
          ${cmd} up "$@"
        '';
      })
      (mkCommand currentSystem {
        name = "ps";
        description = "exec this arion task to ps";
        command = ''
          ${cmd} ps "$@"
        '';
      })
      (mkCommand currentSystem {
        name = "stop";
        description = "arion stop";
        command = ''
          ${cmd} stop "$@"
        '';
      })
      (mkCommand currentSystem {
        name = "rm";
        description = "arion rm";
        command = ''
          ${cmd} rm "$@"
        '';
      })
      (mkCommand currentSystem {
        name = "config";
        description = "check the docker-compose yaml file";
        command = ''
          ${cmd} config "$@"
        '';
      })
      (mkCommand currentSystem {
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
