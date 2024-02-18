{
  inputs,
  std,
  nixpkgs,
}: let
  inherit (builtins) mapAttrs concatStringsSep seq removeAttrs;
  inherit (nixpkgs.lib) splitString drop pipe;
  trimProvisoPath = a:
    if a ? proviso
    then a // {proviso = concatStringsSep "/" (drop 4 (splitString "/" a.proviso));}
    else a;
  evalCommand = a:
    if a ? command
    then seq a.command.outPath a
    else a;

  TargetsExtraData = let
    buildable = {
      drvPath = "drvPath";
      outPath = "outPath";
    };
  in {
    runnables = buildable // {pname = "runnable";};
    installables = buildable;
    files = "file/path";
    nomad = {
      job = {};
    };
    nixago = {
      install = "install";
      configFile = "path/to/configFile";
    };
    nixostests = {
      driver = "driver";
      driverInteractive = "driverInteractive";
    };
    microvms = {
      config.microvm.runner.foo = "42";
      config.microvm.hypervisor = "foo";
    };
    devshells =
      buildable
      // {
        drvAttrs = {
          builder = "builder";
          system = "system";
          name = "devshell";
          args = "args";
        };
      };
    arion = {
      config.out.dockerComposeYaml = "docker-compose.yaml";
    };
    containers =
      buildable
      // {
        name = "name";
        image = {
          name = "repo:tag";
          repo = "repo";
          tag = "tag";
          tags = ["tag" "tag2"];
        };
      };
  };
  InitBlocks = f: n:
    removeAttrs ({
        terra = f n "myrepo";
      }
      .${n}
      or (f n)) ["__functor"];
in
  mapAttrs (
    n: f: let
      bt = InitBlocks f n;
    in (
      if bt ? actions
      then
        bt
        // {
          actions =
            pipe (bt.actions {
              inherit inputs;
              currentSystem = inputs.nixpkgs.system;
              fragment = "f.r.a.g.m.e.n.t";
              fragmentRelPath = "x86/f/r/a/g/m/e/n/t";
              target = TargetsExtraData.${n} or {};
            }) [
              (map trimProvisoPath)
              (map evalCommand)
            ];
        }
      else bt
    )
  )
  std.blockTypes
