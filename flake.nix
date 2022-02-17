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
          theirself =
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
                  self = theirself;
                  inherit (inputs.self) sourceInfo;
                };
            };
            applySuffixes = nixpkgs.lib.attrsets.mapAttrs' (
              suffix: output: let
                baseSuffix =
                  if suffix == ""
                  then ""
                  else "-${suffix}";
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
          in
            builtins.foldl' (
              old: organelle: let
                res = loadCellOrganelle cell organelle cellArgs;
                output =
                  if res != { }
                  then
                    (
                      {
                        "${organelle.name}".${system.build.system} =
                          applySuffixes res;
                      }
                      // (
                        if
                          (
                            organelle.clade
                            == "installables"
                            || organelle.clade == "runnables"
                          )
                          && as-nix-cli-epiphyte
                        then
                          {
                            packages.${system.build.system} =
                              applySuffixes res;
                          }
                        else { }
                      )
                      // (
                        if organelle.clade
                        == "runnables"
                        && as-nix-cli-epiphyte
                        then
                          {
                            apps.${system.build.system} = builtins.mapAttrs (_: toFlakeApp) (applySuffixes res);
                          }
                        else { }
                      )
                    )
                  else { };
              in
                nixpkgs.lib.attrsets.recursiveUpdate old output
            ) { }
            Organelles;
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
          toFlakeApp = drv: let
            name = drv.meta.mainProgram or drv.pname or drv.name;
          in
            {
              program = "${drv}/bin/${name}";
              type = "app";
            };
        in
          theirself;
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
      inherit runnables installables functions grow growOn harvest;
      systems = systems';
    }
    // (
      grow {
        inputs = inputs';
        # as-nix-cli-epiphyte = false;
        cellsFrom = ./cells;
        organelles = [
          (runnables "cli")
          (runnables "lib")
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
