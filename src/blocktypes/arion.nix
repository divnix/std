deSystemize: nixpkgs': let
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
    }: let
      l = nixpkgs.lib // builtins;
      nixpkgs = deSystemize system nixpkgs'.legacyPackages;
      cmd = "arion --prebuilt-file $(nix build $PRJ_ROOT#${fragment}.config.out.dockerComposeYaml --print-out-paths)";
    in [
      {
        name = "up";
        description = "arion up";
        command = nixpkgs.writeShellScriptWithPrjRoot "up" ''
          ${cmd} up "$@"
        '';
      }
      {
        name = "ps";
        description = "exec this arion task to ps";
        command = nixpkgs.writeShellScriptWithPrjRoot "ps" ''
          ${cmd} ps "$@"
        '';
      }
      {
        name = "stop";
        description = "arion stop";
        command = nixpkgs.writeShellScriptWithPrjRoot "stop" ''
          ${cmd} stop "$@"
        '';
      }
      {
        name = "rm";
        description = "arion rm";
        command = nixpkgs.writeShellScriptWithPrjRoot "rm" ''
          ${cmd} rm "$@"
        '';
      }
      {
        name = "config";
        description = "check the docker-compose yaml file";
        command = nixpkgs.writeShellScriptWithPrjRoot "config" ''
          ${cmd} config "$@"
        '';
      }
      {
        name = "arion";
        description = "pass any command to arion";
        command = nixpkgs.writeShellScriptWithPrjRoot "arion" ''
          ${cmd} "$@"
        '';
      }
    ];
  };
in
  arion
