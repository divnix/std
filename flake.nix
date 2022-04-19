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
    validate = import ./validators.nix {inherit (inputs') yants nixpkgs;};
    paths = import ./paths.nix;
    clades = import ./clades.nix;
    incl = import ./incl.nix {inherit nixpkgs;};
    deSystemize = system: s:
      if builtins.isAttrs s && builtins.hasAttr "${system}" s
      then s // s.${system}
      else
        builtins.mapAttrs (
          # _ consumes input's name
          # s -> maybe systems
          _: s:
            if builtins.isAttrs s && builtins.hasAttr "${system}" s
            then s // s.${system}
            else
              builtins.mapAttrs (
                # _ consumes input's output's name
                # s -> maybe systems
                _: s:
                  if builtins.isAttrs s && builtins.hasAttr "${system}" s
                  then (s // s.${system})
                  else s
              )
              s
        )
        s;
    grow = {
      inputs,
      cellsFrom,
      organelles ? [
        (clades.functions "library")
        (clades.runnables "apps")
        (clades.installables "packages")
      ],
      # if true, export installables _also_ as packages and runnables _also_ as apps
      as-nix-cli-epiphyte ? true,
      nixpkgsConfig ? {},
      systems ? (
        nixpkgs.lib.systems.supported.tier1
        ++ nixpkgs.lib.systems.supported.tier2
      ),
      debug ? false,
    }: let
      _debug = s: attrs: let
        traceString = builtins.trace s;
        traceAttrs = nixpkgs.lib.traceSeqN 1 attrs;
        alsoTraceAttrPath = let
          path = nixpkgs.lib.attrsets.attrByPath debug null attrs;
        in
          (builtins.trace "path: ${builtins.concatStringsSep ''.'' debug}") (nixpkgs.lib.traceSeqN 1 path);
        debugIsAttrPath =
          builtins.typeOf debug
          == "list"
          && nixpkgs.lib.attrsets.hasAttrByPath debug attrs;
      in
        if debug == false
        then attrs
        else
          traceString traceAttrs (
            if debugIsAttrPath
            then alsoTraceAttrPath attrs
            else attrs
          );
      # Validations ...
      Organelles = validate.Organelles organelles;
      Systems = validate.Systems systems;
      Cells = nixpkgs.lib.mapAttrsToList (validate.Cell cellsFrom Organelles) (builtins.readDir cellsFrom);
      # Set of all std-injected outputs in the project flake in the outpts and inputs.cells format
      accumulate = builtins.foldl' nixpkgs.lib.attrsets.recursiveUpdate {};
      stdOutput = accumulate (builtins.map stdOutputsFor Systems);
      # List of all flake outputs injected by std in the outputs and inputs.cells format
      stdOutputsFor = system: let
        acc = accumulate (builtins.map (loadCell system) Cells);
        # flatten meta for easier ingestion by the std cli
        meta = {__std.${system} = builtins.attrValues acc.__std.${system};};
      in
        # nixpkgs.lib.traceSeqN 4 meta
        acc
        // meta;
      # Load a cell, return the flake outputs injected by std
      loadCell = system: cellName: let
        cellArgs = {
          inputs = _debug "inputs on ${system}" (
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
              self =
                inputs.self.sourceInfo
                // {rev = inputs.self.sourceInfo.rev or "not-a-commit";};
              cells = deSystemize system (nixpkgs.lib.filterAttrs (k: v: k != "__std") stdOutput);
            }
          );
        };
        # current cell
        cell = let
          op = acc: organelle: let
            args = cellArgs // {inherit cell;};
            res = loadOrganelle organelle args;
          in
            acc
            // (
              if res == {}
              then {}
              else {${organelle.name} = res;}
            );
        in
          builtins.foldl' op {} Organelles;
        loadOrganelle = organelle: args: let
          cPath = paths.cellPath cellsFrom cellName;
          oPath = paths.organellePath cPath organelle;
          importedFile = validate.FileSignature oPath.file (import oPath.file);
          importedDir = validate.FileSignature oPath.dir (import oPath.dir);
        in
          if builtins.pathExists oPath.file
          then validate.Import organelle.clade oPath.file (importedFile args)
          else if builtins.pathExists oPath.dir
          then validate.Import organelle.clade oPath.dir (importedDir args)
          else {};
        # Postprocess the result of the cell loading
        organelles' = nixpkgs.lib.lists.groupBy (x: x.name) Organelles;
        postprocessedOutput =
          nixpkgs.lib.attrsets.mapAttrsToList (
            organelleName: output: let
              organelle = builtins.head organelles'.${organelleName};
              cPath = paths.cellPath cellsFrom cellName;
              oPath = paths.organellePath cPath organelle;
              extractStdMeta = name: output: let
                tPath = paths.targetPath oPath name;
              in {
                name = "${cellName}-${organelleName}-${name}";
                value = {
                  __std_name = name;
                  __std_description =
                    output.meta.description or output.description or "n/a";
                  __std_cell = cellName;
                  __std_clade = organelle.clade;
                  __std_organelle = organelle.name;
                  __std_readme =
                    if builtins.pathExists tPath.readme
                    then tPath.readme
                    else "";
                  __std_cell_readme =
                    if builtins.pathExists cPath.readme
                    then cPath.readme
                    else "";
                  __std_organelle_readme =
                    if builtins.pathExists oPath.readme
                    then oPath.readme
                    else "";
                  __std_actions = [
                    {
                      __action_name = "run";
                      __action_command = ["cowsay" "hi"];
                      __action_description = "run this";
                    }
                  ];
                };
              };
            in {
              ${system}.${cellName}.${organelleName} = output;
              # parseable index of targets for tooling
              __std.${system} = nixpkgs.lib.mapAttrs' extractStdMeta output;
            }
          )
          cell;
        postprocessedCliEpiphyte =
          nixpkgs.lib.attrsets.mapAttrsToList (
            organelleName: output: let
              organelle = builtins.head organelles'.${organelleName};
              isInstallable = organelle.clade == "installables";
              isRunnable = organelle.clade == "runnables";
              applySuffixes = nixpkgs.lib.attrsets.mapAttrs' (
                target: output: let
                  baseSuffix =
                    if target == "default"
                    then ""
                    else "-${target}";
                in {
                  name = "${cellName}${baseSuffix}";
                  value = output;
                }
              );
              toFlakeApp = drv: let
                name = drv.meta.mainProgram or drv.pname or drv.name;
              in {
                program = "${drv}/bin/${name}";
                type = "app";
              };
            in
              if isRunnable
              then {
                packages.${system} = applySuffixes output;
                apps.${system} = builtins.mapAttrs (_: toFlakeApp) (applySuffixes output);
              }
              else if isInstallable
              then {packages.${system} = applySuffixes output;}
              else {}
          )
          cell;
      in
        accumulate (
          postprocessedOutput
          ++ (
            nixpkgs.lib.optionals as-nix-cli-epiphyte
            postprocessedCliEpiphyte
          )
        );
    in
      stdOutput;
    growOn = args: soil:
      nixpkgs.lib.attrsets.recursiveUpdate (
        soil
        // {
          __functor = self: soil': growOn args (nixpkgs.lib.recursiveUpdate soil' self);
        }
      ) (grow args);
    harvest = cellName: outputs: let
      nonEmpty = nixpkgs.lib.attrsets.filterAttrs (_: v: v != {});
      systemList = nixpkgs.lib.systems.doubles.all;
      maybeOrganelles = o: nonEmpty (nixpkgs.lib.attrsets.filterAttrs (_: builtins.isAttrs) o);
      systemOk = o:
        nonEmpty (
          builtins.mapAttrs (
            _: nixpkgs.lib.attrsets.filterAttrs (n: _: builtins.elem n systemList)
          )
          o
        );
      cellOk = cellName: o:
        nonEmpty (
          builtins.mapAttrs (
            _: g:
              nonEmpty (
                builtins.mapAttrs (
                  _: nixpkgs.lib.attrsets.filterAttrs (n: _: nixpkgs.lib.strings.hasPrefix cellName n)
                )
                g
              )
          )
          o
        );
    in
      cellOk cellName (systemOk (maybeOrganelles outputs));
  in
    {
      inherit
        (clades)
        runnables
        installables
        functions
        data
        ;
      inherit
        grow
        growOn
        harvest
        deSystemize
        incl
        ;
      systems = nixpkgs.lib.systems.doubles;
    }
    // (
      grow {
        inputs = inputs';
        # as-nix-cli-epiphyte = false;
        cellsFrom = ./cells;
        organelles = [
          (clades.runnables "cli")
          (clades.functions "lib")
          (clades.functions "devshellProfiles")
        ];
        systems = ["x86_64-linux"];
      }
    );
}
