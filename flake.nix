# SPDX-FileCopyrightText: 2022 The Standard Authors
# SPDX-FileCopyrightText: 2022 Kevin Amado <kamadorueda@gmail.com>
#
# SPDX-License-Identifier: Unlicense
{
  description = "The Nix Flakes framework for perfectionists with deadlines";
  # override downstream with inputs.std.inputs.nixpkgs.follows = ...
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  inputs.yants.url = "github:divnix/yants";
  inputs.yants.inputs.nixpkgs.follows = "nixpkgs";
  outputs = inputs': let
    nixpkgs = inputs'.nixpkgs;
    validate = import ./validators.nix {
      inherit (inputs') yants nixpkgs;
      inherit systems' organellePath;
    };
    organellePath = cellsFrom: cell: organelle: {
      file = "${cellsFrom}/${cell}/${organelle.name}.nix";
      dir = "${cellsFrom}/${cell}/${organelle.name}/default.nix";
    };
    runnables = name: {
      inherit name;
      clade = "runnables";
    };
    installables = name: {
      inherit name;
      clade = "installables";
    };
    functions = name: {
      inherit name;
      clade = "functions";
    };
    data = name: {
      inherit name;
      clade = "data";
    };
    grow =
      let
        defaultSystems = nixpkgs.lib.attrsets.cartesianProductOfSets {
          build = [
            "x86_64-apple-darwin"
            "x86_64-unknown-linux-gnu"
            "aarch64-apple-darwin"
            "aarch64-unknown-linux-gnu"
          ];
          host = builtins.attrNames systems';
        };
      in
        { inputs
        , cellsFrom
        , organelles ? [
            {
              name = "library";
              clade = "functions";
            }
            {
              name = "apps";
              clade = "runnables";
            }
            {
              name = "packages";
              clade = "installables";
            }
          ]
          # if true, export installables _also_ as packages and runnables _also_ as apps
        , as-nix-cli-epiphyte ? true
        , nixpkgsConfig ? { }
        , systems ? defaultSystems
        , debug ? false
        }:
        let
          # Validations ...
          Organelles = validate.Organelles organelles;
          Systems = builtins.map (
            s: {
              build = systems'.${s.build};
              host = systems'.${s.host};
            }
          ) (validate.Systems systems);
          Cells = nixpkgs.lib.mapAttrsToList (validate.Cell cellsFrom Organelles) (builtins.readDir cellsFrom);
          # Set of all std-injected outputs in the project flake
          stdOutput =
            builtins.foldl' nixpkgs.lib.attrsets.recursiveUpdate { } stdOutputs;
          # List of all flake outputs injected by std
          stdOutputs = builtins.concatLists (builtins.map stdOutputsFor Systems);
          stdOutputsFor = system: builtins.map (
            loadCell {
              build = system.build;
              host = system.host;
            }
          )
          Cells;
          # Load a cell, return the flake outputs injected by std
          loadCell = system: cell: let
            cellArgs = {
              inherit system;
              inputs =
                inputs
                // {
                  nixpkgs = import nixpkgs {
                    config =
                      {
                        allowUnfree = true;
                        allowUnsupportedSystem = true;
                        android_sdk.accept_license = true;
                      }
                      // nixpkgsConfig;
                    crossSystem = system.host;
                    localSystem = system.build;
                  };
                  self = inputs.self.sourceInfo;
                  cells = stdOutput;
                };
            };
            applySuffixes = nixpkgs.lib.attrsets.mapAttrs' (
              target: output: let
                baseSuffix =
                  if target == "default"
                  then ""
                  else "-${target}";
                systemSuffix =
                  if system.build.config == system.host.config
                  then ""
                  else "-${system.host.config}";
              in
                {
                  name = "${cell}${baseSuffix}${systemSuffix}";
                  value = output;
                }
            );
            organelles' = nixpkgs.lib.lists.groupBy (x: x.name) Organelles;
            res =
              let
                op = acc: organelle: let
                  output = {
                    ${organelle.name} = loadCellOrganelle cell organelle (cellArgs // { cell = res; });
                  };
                in
                  nixpkgs.lib.attrsets.recursiveUpdate acc output;
              in
                builtins.foldl' op { } Organelles;
            # Postprocess the result of the cell loading
            postprocessedOutput =
              nixpkgs.lib.attrsets.mapAttrsToList (
                organelleName: output: {
                  ${organelleName}.${system.build.system} =
                    applySuffixes output;
                }
              )
              res;
            postprocessedStdMeta =
              nixpkgs.lib.attrsets.mapAttrsToList (
                organelleName: output: let
                  organelle = builtins.head organelles'.${organelleName};
                in
                  {
                    # parseable index of targets for tooling
                    __std.${system.build.system}.${cell}.${organelleName} = builtins.mapAttrs (
                      _: v: {
                        inherit
                          (v)
                          __std_name
                          __std_description
                          __std_cell
                          __std_clade
                          __std_organelle
                          ;
                      }
                    ) (
                      builtins.mapAttrs (toStdTypedOutput cell organelle)
                      output
                    );
                  }
              )
              res;
            postprocessedCliEpiphyte =
              nixpkgs.lib.attrsets.mapAttrsToList (
                organelleName: output: let
                  organelle = builtins.head organelles'.${organelleName};
                  isInstallable = organelle.clade == "installables";
                  isRunnable = organelle.clade == "runnables";
                in
                  if isRunnable
                  then
                    {
                      packages.${system.build.system} = applySuffixes output;
                      apps.${system.build.system} = builtins.mapAttrs (_: toFlakeApp) (applySuffixes output);
                    }
                  else if isInstallable
                  then
                    { packages.${system.build.system} = applySuffixes output; }
                  else { }
              )
              res;
          in
            builtins.foldl' nixpkgs.lib.attrsets.recursiveUpdate { } (
              postprocessedOutput
              ++ postprocessedStdMeta
              ++ (
                nixpkgs.lib.optionals as-nix-cli-epiphyte
                postprocessedCliEpiphyte
              )
            );
          # Each Cell's Organelle can inject a singleton or an attribute set output into the project, not both
          loadCellOrganelle = cell: organelle: cellArgs: let
            path = organellePath cellsFrom cell organelle;
            importedFile = validate.MigrationNecesary path.file (import path.file);
            importedDir = validate.MigrationNecesary path.dir (import path.dir);
          in
            if builtins.pathExists path.file
            then validate.Import organelle.clade path.file (importedFile cellArgs)
            else if builtins.pathExists path.dir
            then
              validate.Import organelle.clade path.dir (importedDir cellArgs)
            else { };
          toStdTypedOutput = cell: organelle: name: output: let
            stdMeta = {
              __std_name =
                output.meta.mainProgram or output.pname or output.name or name;
              __std_description =
                output.meta.description or output.description or "n/a";
              __std_cell = cell;
              __std_clade = organelle.clade;
              __std_organelle = organelle.name;
            };
          in
            (
              if organelle.clade == "functions"
              then stdMeta // { __functor = _: output; }
              else if organelle.clade == "data"
              then stdMeta // { __data = output; }
              else output // stdMeta
            );
          toFlakeApp = drv: let
            name = drv.meta.mainProgram or drv.pname or drv.name;
          in
            {
              program = "${drv}/bin/${name}";
              type = "app";
            };
        in
          stdOutput;
    systems' = nixpkgs.lib.attrsets.mapAttrs' (
      example: config: let
        fullConfig = nixpkgs.lib.systems.elaborate config;
      in
        {
          name = fullConfig.config;
          value = fullConfig;
        }
    ) (builtins.removeAttrs nixpkgs.lib.systems.examples [ "amd64-netbsd" ]);
    growOn = args: soil: nixpkgs.lib.attrsets.recursiveUpdate (
      soil
      // {
        __functor = self: soil': growOn args (nixpkgs.lib.recursiveUpdate soil' self);
      }
    ) (grow args);
    harvest = cell: outputs: let
      nonEmpty = nixpkgs.lib.attrsets.filterAttrs (_: v: v != { });
      systemList = nixpkgs.lib.lists.unique (nixpkgs.lib.attrsets.mapAttrsToList (_: s: s.system) systems');
      maybeOrganelles = o: nonEmpty (nixpkgs.lib.attrsets.filterAttrs (_: builtins.isAttrs) o);
      systemOk = o: nonEmpty (
        builtins.mapAttrs (
          _: nixpkgs.lib.attrsets.filterAttrs (n: _: builtins.elem n systemList)
        )
        o
      );
      cellOk = cell: o: nonEmpty (
        builtins.mapAttrs (
          _: g: nonEmpty (
            builtins.mapAttrs (
              _: nixpkgs.lib.attrsets.filterAttrs (n: _: nixpkgs.lib.strings.hasPrefix cell n)
            )
            g
          )
        )
        o
      );
    in
      cellOk cell (systemOk (maybeOrganelles outputs));
  in
    {
      inherit runnables installables functions data grow growOn harvest;
      systems = systems';
    }
    // (
      grow {
        inputs = inputs';
        # as-nix-cli-epiphyte = false;
        cellsFrom = ./cells;
        organelles = [
          (runnables "cli")
          (functions "lib")
          (functions "devshellProfiles")
        ];
        systems = [
          {
            # GNU/Linux 64 bits
            build = "x86_64-unknown-linux-gnu";
            host = "x86_64-unknown-linux-gnu";
          }
        ];
      }
    );
}
