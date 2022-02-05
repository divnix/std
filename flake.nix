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
  inputs.devshell.url = "github:numtide/devshell";
  inputs.devshell.inputs.nixpkgs.follows = "nixpkgs";
  inputs.treefmt.url = "github:numtide/treefmt";
  inputs.treefmt.inputs.nixpkgs.follows = "nixpkgs";
  inputs.alejandra.url = "github:kamadorueda/alejandra";
  inputs.alejandra.inputs.nixpkgs.follows = "nixpkgs";
  inputs.alejandra.inputs.treefmt.url = "github:divnix/blank";
  outputs = inputs: let
    nixpkgs = inputs.nixpkgs;
    validate = import ./validators.nix {
      inherit (inputs) yants nixpkgs;
      inherit systems organelleFilePath;
    };
    organelleFilePath = cellsFrom: cell: organelle: "${cellsFrom}/${cell}/${organelle.name}.nix";
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
          host = builtins.attrNames systems;
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
          organelles' = validate.Organelles organelles;
          systems' = builtins.map (
            s: {
              build = inputs.self.systems.${s.build};
              host = inputs.self.systems.${s.host};
            }
          ) (validate.Systems systems);
          cells' = nixpkgs.lib.mapAttrsToList (validate.Cell cellsFrom organelles') (builtins.readDir cellsFrom);
          # Set of all std-injected outputs in the project flake
          theirself = builtins.foldl' nixpkgs.lib.attrsets.recursiveUpdate { }
          stdOutputs;
          # List of all flake outputs injected by std
          stdOutputs = builtins.concatLists (builtins.map stdOutputsFor systems');
          stdOutputsFor = system: builtins.map (
            loadCell {
              build = system.build;
              host = system.host;
            }
          )
          cells';
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
                        "${organelle.name}".${system.build.system} = applySuffixes res;
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
                            packages.${system.build.system} = applySuffixes res;
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
            organelles';
          # Each Cell's Organelle can inject a singleton or an attribute set output into the project, not both
          loadCellOrganelle = cell: organelle: cellArgs: let
            filePath = organelleFilePath cellsFrom cell organelle;
          in
            if builtins.pathExists filePath
            then
              validate.ManyPathImport organelle cellsFrom cell (import filePath cellArgs)
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
    systems = nixpkgs.lib.attrsets.mapAttrs' (
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
      systemList = nixpkgs.lib.lists.unique (nixpkgs.lib.attrsets.mapAttrsToList (_: s: s.system) systems);
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
    { inherit runnables installables functions systems grow growOn harvest; }
    // (
      grow {
        inherit inputs;
        # as-nix-cli-epiphyte = false;
        cellsFrom = ./cells;
        organelles = [
          (runnables "devShells")
          (runnables "cli")
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
