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
      inherit organellePath;
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
    deSystemize = system: builtins.mapAttrs (
      # _ consumes input's name
      # s -> maybe systems
      _: s: if builtins.hasAttr "${system}" s
      then s // s.${system}
      else
        builtins.mapAttrs (
          # _ consumes input's output's name
          # s -> maybe systems
          _: s: if builtins.hasAttr "${system}" s
          then (s // s.${system})
          else s
        )
        s
    );
    grow =
      { inputs
      , cellsFrom
      , organelles ? [
          (functions "library")
          (runnables "apps")
          (installables "packages")
        ]
        # if true, export installables _also_ as packages and runnables _also_ as apps
      , as-nix-cli-epiphyte ? true
      , nixpkgsConfig ? { }
      , systems ? (
          nixpkgs.lib.systems.supported.tier1
          ++ nixpkgs.lib.systems.supported.tier2
        )
      , debug ? false
      }:
      let
        # Validations ...
        Organelles = validate.Organelles organelles;
        Systems = validate.Systems systems;
        Cells = nixpkgs.lib.mapAttrsToList (validate.Cell cellsFrom Organelles) (builtins.readDir cellsFrom);
        # Set of all std-injected outputs in the project flake in the outpts and inputs.cells format
        accumulate = builtins.foldl' nixpkgs.lib.attrsets.recursiveUpdate { };
        stdOutput = accumulate (builtins.concatLists (builtins.map stdOutputsFor Systems));
        # List of all flake outputs injected by std in the outputs and inputs.cells format
        stdOutputsFor = system: builtins.map (loadCell system) Cells;
        # Load a cell, return the flake outputs injected by std
        loadCell = system: cell: let
          cellArgs = {
            inputs =
              (deSystemize system inputs)
              // {
                nixpkgs = import nixpkgs {
                  localSystem = system;
                  config =
                    {
                      allowUnfree = true;
                      allowUnsupportedSystem = true;
                      android_sdk.accept_license = true;
                    }
                    // nixpkgsConfig;
                };
                self = inputs.self.sourceInfo;
                cells = stdOutput // stdOutput.${system};
              };
          };
          applySuffixes = nixpkgs.lib.attrsets.mapAttrs' (
            target: output: let
              baseSuffix =
                if target == "default"
                then ""
                else "-${target}";
            in
              {
                name = "${cell}${baseSuffix}";
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
              organelleName: output: { ${system}.${cell}.${organelleName} = output; }
            )
            res;
          postprocessedStdMeta =
            nixpkgs.lib.attrsets.mapAttrsToList (
              organelleName: output: let
                organelle = builtins.head organelles'.${organelleName};
              in
                {
                  # parseable index of targets for tooling
                  __std.${system}.${cell}.${organelleName} = nixpkgs.lib.attrsets.mapAttrs' (
                    k: v: {
                      name =
                        if k == "default"
                        then ""
                        else k;
                      value = {
                        inherit
                          (v)
                          __std_name
                          __std_description
                          __std_cell
                          __std_clade
                          __std_organelle
                          ;
                      };
                    }
                  ) (
                    builtins.mapAttrs (toStdTypedOutput cell organelle) output
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
                    packages.${system} = applySuffixes output;
                    apps.${system} = builtins.mapAttrs (_: toFlakeApp) (applySuffixes output);
                  }
                else if isInstallable
                then { packages.${system} = applySuffixes output; }
                else { }
            )
            res;
        in
          accumulate (
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
          then validate.Import organelle.clade path.dir (importedDir cellArgs)
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
    growOn = args: soil: nixpkgs.lib.attrsets.recursiveUpdate (
      soil
      // {
        __functor = self: soil': growOn args (nixpkgs.lib.recursiveUpdate soil' self);
      }
    ) (grow args);
    harvest = cell: outputs: let
      nonEmpty = nixpkgs.lib.attrsets.filterAttrs (_: v: v != { });
      systemList = nixpkgs.lib.systems.doubles.all;
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
      inherit
        runnables
        installables
        functions
        data
        grow
        growOn
        harvest
        deSystemize
        ;
      systems = nixpkgs.lib.systems.doubles;
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
        systems = [ "x86_64-linux" ];
      }
    );
}
