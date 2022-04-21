{
  nixpkgs,
  yants,
}: let
  l = nixpkgs.lib // builtins;
  deSystemize = import ./de-systemize.nix;
  paths = import ./paths.nix;
  clades = import ./clades.nix {inherit nixpkgs;};
  validate = import ./validators.nix {inherit yants nixpkgs;};
in
  {
    inputs,
    cellsFrom,
    organelles ? [
      (clades.functions "library")
      (clades.runnables "apps")
      (clades.installables "packages")
    ],
    nixpkgsConfig ? {},
    systems ? (
      l.systems.supported.tier1
      ++ l.systems.supported.tier2
    ),
    debug ? false,
  }: let
    _debug = s: attrs: let
      traceString = l.trace s;
      traceAttrs = l.traceSeqN 1 attrs;
      alsoTraceAttrPath = let
        path = l.attrsets.attrByPath debug null attrs;
      in
        (l.trace "path: ${l.concatStringsSep ''.'' debug}") (l.traceSeqN 1 path);
      debugIsAttrPath =
        l.typeOf debug
        == "list"
        && l.attrsets.hasAttrByPath debug attrs;
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
    Cells = l.mapAttrsToList (validate.Cell cellsFrom Organelles) (l.readDir cellsFrom);
    # Set of all std-injected outputs in the project flake in the outpts and inputs.cells format
    accumulate = l.foldl' l.attrsets.recursiveUpdate {};
    stdOutput = accumulate (l.map stdOutputsFor Systems);
    # List of all flake outputs injected by std in the outputs and inputs.cells format
    stdOutputsFor = system: let
      acc = accumulate (l.map (loadCell system) Cells);
      meta = {
        # materialize meta & also realize all implicit runtime dependencies
        __std.${system} = nixpkgs.legacyPackages.${system}.writeTextFile {
          name = "__std-${system}.json";
          # flatten meta for easier ingestion by the std cli
          text = l.toJSON (l.attrValues acc.__std.${system});
        };
      };
    in
      # l.traceSeqN 4 meta
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
            cells = deSystemize system (l.filterAttrs (k: v: k != "__std") stdOutput);
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
        l.foldl' op {} Organelles;
      loadOrganelle = organelle: args: let
        cPath = paths.cellPath cellsFrom cellName;
        oPath = paths.organellePath cPath organelle;
        importedFile = validate.FileSignature oPath.file (import oPath.file);
        importedDir = validate.FileSignature oPath.dir (import oPath.dir);
      in
        if l.pathExists oPath.file
        then validate.Import organelle.clade oPath.file (importedFile args)
        else if l.pathExists oPath.dir
        then validate.Import organelle.clade oPath.dir (importedDir args)
        else {};
      # Postprocess the result of the cell loading
      organelles' = l.lists.groupBy (x: x.name) Organelles;
      postprocessedOutput =
        l.attrsets.mapAttrsToList (
          organelleName: output: let
            organelle = l.head organelles'.${organelleName};
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
                  if l.pathExists tPath.readme
                  then tPath.readme
                  else "";
                __std_cell_readme =
                  if l.pathExists cPath.readme
                  then cPath.readme
                  else "";
                __std_organelle_readme =
                  if l.pathExists oPath.readme
                  then oPath.readme
                  else "";
                __std_actions =
                  if organelle ? actions
                  then
                    organelle.actions {
                      inherit system;
                      flake = inputs.self.sourceInfo.outPath;
                      fragment = ''"${system}"."${cellName}"."${organelleName}"."${name}"'';
                    }
                  else [];
              };
            };
          in {
            ${system}.${cellName}.${organelleName} = output;
            # parseable index of targets for tooling
            __std.${system} = l.mapAttrs' extractStdMeta output;
          }
        )
        cell;
    in
      accumulate postprocessedOutput;
  in
    stdOutput
