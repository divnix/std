{
  inputs,
  std,
  nixpkgs,
}: let
  inherit (builtins) mapAttrs concatStringsSep seq;
  inherit (nixpkgs.lib) splitString drop pipe;
  trimProvisoPath = a:
    if a ? proviso
    then a // {proviso = concatStringsSep "/" (drop 4 (splitString "/" a.proviso));}
    else a;
  evalCommand = a:
    if a ? command
    then seq a.command.outPath a
    else a;
in
  mapAttrs (
    n: f: let
      action = builtins.removeAttrs ({
          terra = f n "myrepo";
        }
        .${n}
        or (f n)) ["__functor"];
      buildable = {
        drvPath = "drvPath";
        outPath = "outPath";
      };
      targets = {
        runnables = buildable // {pname = "runnable";};
        installables = buildable;
        files = "file/path";
        nomad = {
          job = {};
        };
        nixago = {
          install = "install";
          config = "path/to/config";
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
    in (
      if action ? actions
      then
        action
        // {
          actions =
            pipe (action.actions {
              inherit inputs;
              currentSystem = inputs.nixpkgs.system;
              fragment = "f.r.a.g.m.e.n.t";
              fragmentRelPath = "x86/f/r/a/g/m/e/n/t";
              target = targets.${n} or {};
            }) [
              (map trimProvisoPath)
              (map evalCommand)
            ];
        }
      else action
    )
  )
  std.blockTypes
