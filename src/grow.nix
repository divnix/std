{
  nixpkgs,
  yants,
}: let
  l = nixpkgs.lib // builtins;
  deSystemize = import ./de-systemize.nix;
  paths = import ./paths.nix;
  clades = import ./clades.nix {inherit nixpkgs;};
  validate = import ./validators.nix {inherit yants nixpkgs;};
  builtinNixpkgsConfig = {
    allowUnfree = true;
    allowUnsupportedSystem = true;
    android_sdk.accept_license = true;
  };
  /*
   A funtion that 'grows' 'organells' from 'cells' found in 'cellsFrom'.

   This figurative glossary is so non-descriptive, yet fitting, that
   it will be easy to reason about this nomenclature even in a casual
   conversation when not having convenient access to the actual code.

   Essentially, it is a special type of importer, that detects nix &
   some companion files placed in a specific folder structure inside
   your repository.

   The root of that special folder hierarchy is declared via 'cellsFrom'.
   This is a good opportunity to isolate your actual build-relevant source
   code from other repo boilerplate or documentation as a first line measure
   to improve build caching.

   Organelles are the actual typed flake outputs, for convenience, organelles
   are grouped into Clades which usually augment an organelle with action
   definitions that the std TUI will be able to understand and execute.

   The usual dealings with 'system' are greatly reduced in std. Inspired by
   the ideas known partly as "Super Simple Flakes" in the community, contrary
   to clasical nix, _all_ oututs are simply scoped by system as the first-level
   output key. That's it. Never deal with it again. The 'deSystemize' function
   automatically folds any particular system scope of inputs automatically one
   level up. So,when dealing with inputs, no dealing with 'system' either.

   If you need to crosscompile and know your current system, `inputs.nixpkgs.system`
   always has it. and all other inputs still expose `inputs.foo.system` as a
   fall back. But use your escape hatch wisely. If you feel that you need it and
   you aren't doing cross-compilation, search for the upstream bug.
   It's there! Guaranteed!

   Debugging? You can gain a better understanding of the `inputs` argument by
   declaring the debug attribute for example like so: `debug = ["inputs" "yants"];`
   A tracer will give you more context about what's in it for you.

   Finally, there are a couple of special inputs:

   - `inputs.cells` - all other cells, deSystemized
   - `inputs.nixpkgs` - an _instatiated_ nixpkgs, configurabe via `nixpkgsConifg`
   - `inpugs.self` - the `sourceInfo` (and only that) of the current flake

   Overlays? Go home or file an upstream bug. They are possible, but so heavily
   discouraged that you gotta find out for yourself if you really need to use
   them in an organelle. Hint: `.extend`.

   Yes, std is opinionated. Make sure to also meet `alejandra`. 😎

   */
  grow = {
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
              config = builtinNixpkgsConfig // nixpkgsConfig;
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
                      fragmentRelPath = "${cellName}/${organelleName}/${name}";
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
    stdOutput;
in
  grow
