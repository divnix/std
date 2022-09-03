{
  nixpkgs,
  yants,
}: let
  l = nixpkgs.lib // builtins;
  deSystemize = import ./de-systemize.nix;
  paths = import ./paths.nix;
  blockTypes = import ./blocktypes.nix {inherit nixpkgs;};
  validate = import ./validators.nix {inherit yants nixpkgs;};
  /*
  A function that 'grows' Cell Blocks from Cells found in 'cellsFrom'.

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

  Cell Blocks are the actual typed flake outputs, for convenience, Cell Blocks
  are grouped into Blocktypes which usually augment an Cell Block with action
  definitions that the std TUI will be able to understand and execute.

  The usual dealings with 'system' are greatly reduced in std. Inspired by
  the ideas known partly as "Super Simple Flakes" in the community, contrary
  to clasical nix, _all_ outputs are simply scoped by system as the first-level
  output key. That's it. Never deal with it again. The 'deSystemize' function
  automatically folds any particular system scope of inputs automatically one
  level up. So, when dealing with inputs, no dealing with 'system' either.

  If you need to crosscompile and know your current system, `inputs.nixpkgs.system`
  always has it. And all other inputs still expose `inputs.foo.system` as a
  fall back. But use your escape hatch wisely. If you feel that you need it and
  you aren't doing cross-compilation, search for the upstream bug.
  It's there! Guaranteed!

  Debugging? You can gain a better understanding of the `inputs` argument by
  declaring the debug attribute for example like so: `debug = ["inputs" "yants"];`.
  A tracer will give you more context about what's in it for you.

  Finally, there are a couple of special inputs:

  - `inputs.cells` - all other cells, deSystemized
  - `inputs.nixpkgs` - an _instatiated_ nixpkgs, configurabe via `nixpkgsConfig`
  - `inputs.self` - the `sourceInfo` (and only that) of the current flake

  Overlays? Go home or file an upstream bug. They are possible, but so heavily
  discouraged that you gotta find out for yourself if you really need to use
  them in an Cell Block. Hint: `.extend`.

  Yes, std is opinionated. Make sure to also meet `alejandra`. 😎

  */
  grow = {
    inputs,
    cellsFrom,
    organelles ? null,
    cellBlocks ? [
      (blockTypes.functions "library")
      (blockTypes.runnables "apps")
      (blockTypes.installables "packages")
    ],
    systems ? [
      # Tier 1
      "x86_64-linux"
      # Tier 2
      "aarch64-linux"
      "x86_64-darwin"
      # Other platforms with sufficient support in stdenv which is not formally
      # mandated by their platform tier.
      "aarch64-darwin" # a lot of apple M1 already out there
    ],
    debug ? false,
  }: let
    # Validations ...
    CellBlocks =
      if organelles != null
      then
        l.warn ''

          Standard (divnix/std): Screw the wired naming!!! Finally.

          Please rename:

          - sed -i 's/organelles/cellBlocks/g'
          - sed -i 's/organelle/cellBlock/g'
          - sed -i 's/Organelles/Cell Blocks/g'
          - sed -i 's/Organelle/Cell Block/g'

          (In project: ${toString inputs.self})

          see: https://github.com/divnix/std/issues/116
        ''
        validate.CellBlocks
        organelles
      else validate.CellBlocks cellBlocks;
    Systems = validate.Systems systems;
    Cells = l.mapAttrsToList (validate.Cell cellsFrom CellBlocks) (l.readDir cellsFrom);

    # Helpers ...
    accumulate =
      l.foldl'
      (acc: new: let
        car = l.head new;
        cdr = l.tail new;
      in {
        output = acc.output // car;
        actions = acc.actions // (l.head cdr);
        init = acc.init ++ (l.tail cdr);
      })
      {
        output = {};
        actions = {};
        init = [];
      };

    optionalLoad = cond: elem:
      if cond
      then elem
      else [{} {} {}];

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

    cells' = res.output;
    # List of all flake outputs injected by std in the outputs and inputs.cells format
    loadOutputFor = system: let
      # Load a cell, return the flake outputs injected by std
      args.inputs = _debug "inputs on ${system}" (
        (deSystemize system inputs)
        // {
          self =
            inputs.self.sourceInfo
            // {rev = inputs.self.sourceInfo.rev or "not-a-commit";};
          # recursion on cells
          cells = deSystemize system cells';
        }
        // l.optionalAttrs (inputs ? nixpkgs) {
          nixpkgs = deSystemize system nixpkgs.legacyPackages;
        }
      );
      loadCellFor = cellName: let
        cPath = paths.cellPath cellsFrom cellName;
        loadCellBlock = cellBlock: let
          oPath = paths.cellBlockPath cPath cellBlock;
          importedFile = validate.FileSignature oPath.file (import oPath.file);
          importedDir = validate.FileSignature oPath.dir (import oPath.dir);
          # minimum data for initializing TUI / CLI completion
          extractInitMeta = name: target: let
            tPath = paths.targetPath oPath name;
            actions =
              if cellBlock ? actions
              then
                cellBlock.actions {
                  inherit system;
                  flake = inputs.self.sourceInfo.outPath;
                  fragment = ''"${system}"."${cellName}"."${cellBlock.name}"."${name}"'';
                  fragmentRelPath = "${cellName}/${cellBlock.name}/${name}";
                }
              else [];
          in {
            inherit name;
            deps = target.meta.after or target.after or [];
            description = target.meta.description or target.description or "n/a";
            readme =
              if l.pathExists tPath.readme
              then tPath.readme
              else "";
            # for speed only extract name & description, the bare minimum for display
            actions = map (a: {inherit (a) name description;}) actions;
          };
          # lazy action command renedering (slow)
          extractActionsMeta = name: target: let
            actions =
              if cellBlock ? actions
              then
                cellBlock.actions {
                  inherit system;
                  flake = inputs.self.sourceInfo.outPath;
                  fragment = ''"${system}"."${cellName}"."${cellBlock.name}"."${name}"'';
                  fragmentRelPath = "${cellName}/${cellBlock.name}/${name}";
                }
              else [];
          in
            l.listToAttrs (map (a: {
                inherit (a) name;
                value = nixpkgs.legacyPackages.${system}.writeShellScript a.name a.command;
              })
              actions);
          imported =
            if l.pathExists oPath.file
            then
              validate.Import cellBlock.type oPath.file (importedFile (
                args // {cell = res.output;} # recursion on cell
              ))
            else if l.pathExists oPath.dir
            then
              validate.Import cellBlock.type oPath.dir (importedDir (
                args // {cell = res.output;} # recursion on cell
              ))
            else null;
        in
          optionalLoad (imported != null)
          [
            {${cellBlock.name} = imported;}
            # __std meta actions (slow)
            {${cellBlock.name} = l.mapAttrs extractActionsMeta imported;}
            # __std meta init (fast)
            {
              cellBlock = cellBlock.name;
              blockType = cellBlock.type;
              readme =
                if l.pathExists oPath.readme
                then oPath.readme
                else "";
              targets = l.mapAttrsToList extractInitMeta imported;
            }
          ];
        res = accumulate (l.map loadCellBlock CellBlocks);
      in
        optionalLoad (res != {})
        [
          {${cellName} = res.output;}
          # __std meta actions (slow)
          {${cellName} = res.actions;}
          # __std meta init (fast)
          {
            cell = cellName;
            readme =
              if l.pathExists cPath.readme
              then cPath.readme
              else "";
            cellBlocks = res.init; # []
          }
        ]; # };
      res = accumulate (l.map loadCellFor Cells);
    in
      optionalLoad (res != {})
      [
        {${system} = res.output;}
        # __std meta actions (slow)
        {${system} = res.actions;}
        # __std meta init (fast)
        {
          name = system;
          value = res.init;
        }
      ];
    res = accumulate (l.map loadOutputFor Systems);
  in
    res.output
    # meta = {
    #   # materialize meta & also realize all implicit runtime dependencies
    #   __std.${system}.targets = nixpkgs.legacyPackages.${system}.writeTextFile {
    #     name = "__std-${system}-targets.json";
    #     # flatten meta for easier ingestion by the std cli
    #     text = l.toJSON (l.attrValues acc.__std.${system}.targets);
    #   };
    // {
      __std.init = l.listToAttrs res.init;
      __std.actions = res.actions;
      __std.direnv_lib = ../direnv_lib.sh;
    };
in
  grow
