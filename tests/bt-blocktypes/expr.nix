{
  inputs,
  std,
  nixpkgs,
}: let
  inherit (builtins) mapAttrs concatStringsSep seq removeAttrs derivation;
  inherit (nixpkgs.lib) splitString drop pipe optionalAttrs;
  inherit (nixpkgs.stdenv) isLinux;
  inherit (std) dmerge;
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
  # fake snapshot compliance across systems
  FakeActionsForOtherSystems = let
    fakeDrv = name:
      derivation {
        inherit name;
        system = "fake";
        builder = "/bin/sh";
      };
  in
    optionalAttrs (!isLinux) {
      nixostests = dmerge.append [
        {
          command = fakeDrv "iptables+";
          description = "setup nat redirect 80->8080 & 443->4433";
          name = "iptables+";
        }
        {
          command = fakeDrv "iptables-";
          description = "remove nat redirect 80->8080 & 443->4433";
          name = "iptables-";
        }
      ];
    };
in
  mapAttrs (
    n: f: let
      bt = InitBlocks f n;
    in (
      if bt ? actions
      then
        bt
        // {
          actions = let
            actions' = bt.actions {
              inherit inputs;
              currentSystem = inputs.nixpkgs.system;
              fragment = "f.r.a.g.m.e.n.t";
              fragmentRelPath = "x86/f/r/a/g/m/e/n/t";
              target = TargetsExtraData.${n} or {};
            };
            r =
              (
                dmerge {${n} = actions';} FakeActionsForOtherSystems
              )
              .${n};
          in
            pipe r [
              (map trimProvisoPath)
              (map evalCommand)
            ];
        }
      else bt
    )
  )
  std.blockTypes
