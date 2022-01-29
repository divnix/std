{
  description = "The Nix Flakes framework for perfectionists with deadlines";

  # override downstream with inputs.std.inputs.nixpkgs.follows = ...
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

  inputs.devshell.url = "github:numtide/devshell";
  inputs.treefmt.url = "github:numtide/treefmt";
  inputs.treefmt.inputs.nixpkgs.follows = "nixpkgs";
  inputs.alejandra.url = "github:kamadorueda/alejandra";
  inputs.alejandra.inputs.nixpkgs.follows = "nixpkgs";

  outputs = { nixpkgs, devshell, treefmt, alejandra, ... } @ inputs:
    let

      # organelleName is constructed from the singleton name if defined, else form the plural
      organelleName = organelle: organelle.m or organelle.o;

      # organellePaths are constructed from the specified organelles
      organellePaths = cellsFrom: cell: organelle:
        (if organelle ? o then { onePath = "${cellsFrom}/${cell}/${organelle.o}.nix"; } else { }) //
        (if organelle ? m then { manyPath = "${cellsFrom}/${cell}/${organelle.m}.nix"; } else { })
      ;
      organellePathsList = cellsFrom: cell: organelle:
        nixpkgs.lib.reverseList
          (builtins.attrValues (organellePaths cellsFrom cell organelle));
      prefixWithCellsFrom = path:
        builtins.concatStringsSep
          "/"
          (
            [ "\${cellsFrom}" ] ++
            (nixpkgs.lib.lists.drop
              4
              (nixpkgs.lib.splitString
                "/"
                path
              )
            )
          );

      validate = {
        System = systemPair:
          let
            allKeysValid =
              builtins.all
                (k: builtins.elem k [ "build" "host" ])
                (builtins.attrNames systemPair)
            ;
            allKeysPresent =
              builtins.all
                (k: builtins.elem k (builtins.attrNames systemPair))
                [ "build" "host" ]
            ;
            buildValueIsValid =
              builtins.hasAttr systemPair.build inputs.self.systems;
            hostValueIsValid =
              builtins.hasAttr systemPair.host inputs.self.systems;
          in
          if ! allKeysValid
          then
            abort ''


              The following system has invalid key(s):
              Keys: '${builtins.attrNames systemPair}'

              Valid keys are: 'build' & 'host'
            ''
          else if ! allKeysPresent
          then
            abort ''


              The following system lacks a key:
              Keys: '${builtins.attrNames systemPair}'

              Required keys are: 'build' & 'host'
            ''
          else if ! buildValueIsValid
          then
            abort ''


              System build value '${systemPair.build}' is not valid.
              Please pick one from the following:

              ${builtins.concatStringsSep "\n"
                (builtins.attrNames inputs.self.systems)}

            ''
          else if ! hostValueIsValid
          then
            abort ''


              System build value '${systemPair.host}' is not valid.
              Please pick one from the following:

              ${builtins.concatStringsSep "\n"
                (builtins.attrNames inputs.self.systems)}

            ''
          else {
            build = inputs.self.systems.${systemPair.build};
            host = inputs.self.systems.${systemPair.host};
          };
        Cell = cellsFrom: organelles: cell: type:
          let
            atLeastOneOrganelle =
              builtins.any
                builtins.pathExists
                (nixpkgs.lib.lists.flatten
                  (builtins.map
                    (organellePathsList cellsFrom cell)
                    organelles
                  )
                )
            ;
            badOrganelles = builtins.filter
              (organelle:
                builtins.length (organellePathsList cellsFrom cell organelle) > 1 &&
                builtins.all builtins.pathExists (organellePathsList cellsFrom cell organelle)
              );
          in
          if type != "directory"
          then
            abort ''


              Everything under ''${cellsFrom}/* is considered a Cell

              Cells are directories by convention and therefore
              only directories are allowed at ''${cellsFrom}/*

              Please remove ${"'"}''${cellsFrom}/${cell}' and don't forget to add the change to version control.

            ''
          else if ! atLeastOneOrganelle
          then
            abort ''


              For Cell '${cell}' to be useful
              it needs to provide at least one Organelle

              In this project, the Organelles of a Cell can be
              ${builtins.concatStringsSep ", " (builtins.map organelleName organelles) }


              ${
                builtins.concatStringsSep
                  "\n\n"
                  (builtins.map
                    (organelle: let
                      numerator = if (organelle ? o && organelle ? m) then "one or more outputs" else if (organelle ? o) then "the single output" else "outputs";
                      title = "To generate ${numerator} for Organelle '${organelleName organelle}', please create:\n";
                      list = "${
                        builtins.concatStringsSep
                          " or\n"
                          (builtins.map
                            (p: "  - ${prefixWithCellsFrom p}")
                            (organellePathsList cellsFrom cell organelle)
                          )
                      }";
                    in title + list)
                    organelles
                  )
              }

              Please create at least one of the previous files and don't forget to add them to version control.
            ''
          else if builtins.length (badOrganelles organelles) != 0
          then
            abort ''


              Cell Organelles can inject eiter a singleton output or an attribute set of outputs into the project flake, not both.
              Hence, please use only one of the following files:

              ${
                builtins.concatStringsSep
                  "\n\n"
                  (builtins.map
                    (organelle:
                      (builtins.concatStringsSep
                        " or\n"
                        (builtins.map
                          (p: "  - ${prefixWithCellsFrom p}")
                          (organellePathsList cellsFrom cell organelle)
                        )
                      )
                    )
                    (badOrganelles organelles)
                  )
              }

              Please remove either one and don't forget to add the changes to version control.

            ''
          else cell;
        Organelle = organelle:
          if ! (organelle ? o || organelle ? m)
          then
            abort ''


              An Organelle must either have a "one" or "many" name or both.
              Please define in your organelles:
                - either { o = "one-name"; }
                - or { m = "many-name"; }
                - or both

            ''
          else if ! (builtins.elem organelle.clade [
            "runnables"
            "installables"
            "functions"
          ])
          then
            abort ''


              An Organelle must be of one of the following clades:
                - runnables
                - installables
                - functions

              Please define in your organelle ${organelleName organelle}:
              { clade = "<clade>"; }

            ''
          else organelle;
      };

      runnables = attrs: validate.Organelle (attrs // { clade = "runnables"; });
      installables = attrs: validate.Organelle (attrs // { clade = "installables"; });
      functions = attrs: validate.Organelle (attrs // { clade = "functions"; });

      grow =
        let
          defaultSystems = nixpkgs.lib.attrsets.cartesianProductOfSets {
            build = [
              "x86_64-apple-darwin"
              "x86_64-unknown-linux-gnu"
              "aarch64-apple-darwin"
              "aarch64-unknown-linux-gnu"
            ];
            host = builtins.attrNames inputs.self.systems;
          };

        in
        { inputs
        , cellsFrom

        , organelles ? [
            { o = "function"; m = "functions"; clade = "functions"; }
            { o = "app"; m = "apps"; clade = "runnables"; }
            { o = "package"; m = "packages"; clade = "installables"; }
          ]

          # if true, export installables _also_ as packages and runnables _also_ as apps
        , as-nix-cli-epiphyte ? true

        , nixpkgsConfig ? { }
        , nixpkgsOverlays ? [ ]
        , nixpkgsCrossOverlays ? [ ]

        , systems ? defaultSystems
        , debug ? false
        }:
        let
          # Validations ...
          organelles' = builtins.map validate.Organelle organelles;
          systems' = builtins.map validate.System systems;
          cells' = nixpkgs.lib.mapAttrsToList (validate.Cell cellsFrom organelles') (builtins.readDir cellsFrom);

          # Set of all std-injected outputs in the project flake
          theirself = builtins.foldl'
            nixpkgs.lib.attrsets.recursiveUpdate
            { }
            stdOutputs;

          # List of all flake outputs injected by std
          stdOutputs = builtins.concatLists (builtins.map stdOutputsFor systems');
          stdOutputsFor = system:
            builtins.map
              (loadCell {
                build = system.build;
                host = system.host;
              })
              cells';

          # Load a cell, return the flake outputs injected by std
          loadCell = system: cell:
            let
              cellArgs = {
                inherit system;
                inputs = inputs // {
                  nixpkgs = import nixpkgs {
                    config = {
                      allowUnfree = true;
                      allowUnsupportedSystem = true;
                      android_sdk.accept_license = true;
                    } // nixpkgsConfig;
                    crossOverlays = nixpkgsCrossOverlays;
                    crossSystem = system.host;
                    localSystem = system.build;
                    overlays = nixpkgsOverlays;
                  };
                  nixpkgsSrc = nixpkgs;
                  self = theirself;
                };
              };

              applySuffixes = nixpkgs.lib.attrsets.mapAttrs'
                (suffix: output:
                  let
                    baseSuffix = if suffix == "" then "" else "-${suffix}";
                    systemSuffix =
                      if system.build.system == system.host.system
                      then "" else "-${system.host.config}";
                  in
                  {
                    name = "${cell}${baseSuffix}${systemSuffix}";
                    value = output;
                  });
            in
            builtins.foldl'
              (old: organelle:
                let
                  res = loadCellOrganelle cell organelle cellArgs;
                  output =
                    if res != { }
                    then
                      (
                        {
                          "${organelleName organelle}".${system.build.system} = applySuffixes res;
                        } // (
                          if (organelle.clade == "installables" || organelle.clade == "runnables") && as-nix-cli-epiphyte
                          then { packages.${system.build.system} = applySuffixes res; }
                          else { }
                        ) // (
                          if organelle.clade == "runnables" && as-nix-cli-epiphyte
                          then { apps.${system.build.system} = builtins.mapAttrs (_: toFlakeApp) (applySuffixes res); }
                          else { }
                        )
                      )
                    else { };
                in
                nixpkgs.lib.attrsets.recursiveUpdate old output
              )
              { }
              organelles';

          # Each Cell's Organelle can inject a singleton or an attribute set output into the project, not both
          loadCellOrganelle = cell: organelle: cellArgs:
            let
              onePath = (organellePaths cellsFrom cell organelle).onePath or null;
              manyPath = (organellePaths cellsFrom cell organelle).manyPath or null;
              validateOnePathImport = imported:
                if builtins.isAttrs imported && ! nixpkgs.lib.isDerivation imported
                then
                  abort ''


                    The following file does contain an attribute set:
                      - ${prefixWithCellsFrom onePath}

                    ${
                      if manyPath != null
                      then "If you need several outputs, rename to:\n  - ${prefixWithCellsFrom manyPath}\n\nOtherwise, it must contain only a single output."
                      else "But it must contain only a single output."
                    }
                  ''
                else if organelle.clade == "functions" && ! builtins.isFunction imported
                then
                  abort ''


                    The following file of Clade 'functions' doesn't contain a function:
                      - ${prefixWithCellsFrom onePath}

                    But single output organelles of Clade 'function' must resolve to a single function.
                  ''
                else imported;

              validateManyPathImport = imported:
                if ! builtins.isAttrs imported || nixpkgs.lib.isDerivation imported
                then
                  abort ''


                    The following file doesn't contain an attribute set:
                      - ${prefixWithCellsFrom manyPath}

                    ${
                      if onePath != null
                      then "If you only need one single output, consider renaming to:\n  - ${prefixWithCellsFrom onePath}\n\nOtherwise, it must contain an attribute set of outputs."
                      else "But it must contain an attribute set of outputs."
                    }
                  ''
                else imported;
            in
            if onePath != null && builtins.pathExists onePath
            then { "" = validateOnePathImport (import onePath cellArgs); }
            else if manyPath != null && builtins.pathExists manyPath
            then validateManyPathImport (import manyPath cellArgs)
            else { };

          toFlakeApp = drv:
            let name = drv.meta.mainProgram or drv.pname or drv.name;
            in { program = "${drv}/bin/${name}"; type = "app"; };
        in
        theirself;

      systems = nixpkgs.lib.attrsets.mapAttrs'
        (example: config:
          let fullConfig = nixpkgs.lib.systems.elaborate config;
          in { name = fullConfig.config; value = fullConfig; })
        (builtins.removeAttrs
          nixpkgs.lib.systems.examples
          [ "amd64-netbsd" ]);
    in
    {
      inherit runnables installables functions systems grow;

    } // (grow {
      inherit inputs;
      as-nix-cli-epiphyte = false;
      cellsFrom = ./cells;
      organelles = [ (runnables rec { o = "devShell"; m = o + "s"; }) ];
      nixpkgsOverlays = [
        devshell.overlay
        (super: self: { treefmt = treefmt.defaultPackage.${self.system}; })
        (super: self: { alejandra = alejandra.defaultPackage.${self.system}; })
      ];
      systems = [{
        build = "x86_64-unknown-linux-gnu"; # GNU/Linux 64 bits
        host = "x86_64-unknown-linux-gnu"; # GNU/Linux 64 bits
      }];
    });
}
