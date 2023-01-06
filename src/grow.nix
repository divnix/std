{
  nixpkgs,
  yants,
  deSystemize,
}: let
  l = nixpkgs.lib // builtins;
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
  are grouped into Block Types which usually augment a Cell Block with action
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
  them in a Cell Block. Hint: `.extend`.

  Yes, std is opinionated. Make sure to also meet `alejandra`. 😎

  */
  grow = {
    inputs,
    cellsFrom,
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
    nixpkgsConfig ? {},
  }: let
    # Validations ...
    CellBlocks = let
      unique =
        l.foldl' (
          acc: e:
            if l.elem e.name acc.visited
            then acc
            else {
              visited = acc.visited ++ [e.name];
              result = acc.result ++ [e];
            }
        ) {
          visited = [];
          result = [];
        };
    in
      (unique
        (validate.CellBlocks cellBlocks))
      .result;
    Systems = validate.Systems systems;
    Cells = l.mapAttrsToList (validate.Cell cellsFrom CellBlocks) (l.readDir cellsFrom);

    # Helpers ...
    accumulate =
      l.foldl'
      (
        acc: new: let
          first = l.head new;
          second = l.head cdr;
          third = l.head cdr';
          fourth = l.head cdr_;
          tail = l.tail cdr_;

          cdr = l.tail new;
          cdr' = l.tail cdr;
          cdr_ = l.tail cdr';
        in
          (
            if first == null
            then {inherit (acc) output;}
            else {output = acc.output // first;}
          )
          // (
            if second == null
            then {inherit (acc) actions;}
            else {actions = acc.actions // second;}
          )
          // (
            if third == null
            then {inherit (acc) init;}
            else {init = acc.init ++ [third];}
          )
          // (
            if fourth == null
            then {inherit (acc) ci;}
            else {ci = acc.ci ++ (l.concatMap (t: l.flatten t.ci) [fourth]);}
          )
          // (
            if tail == [null]
            then {inherit (acc) ci';}
            else {ci' = acc.ci' ++ (l.concatMap (t: l.flatten t.ci') tail);}
          )
      )
      {
        output = {};
        actions = {};
        init = [];
        ci = [];
        ci' = []; # with drv (eval-costly)
      };

    optionalLoad = cond: elem:
      if cond
      then elem
      else [
        null # empty output
        null # empty action
        null # empty init
        null # empty ci
      ];

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
          nixpkgs = let
            config = nixpkgsConfig;
          in
            (import inputs.nixpkgs {inherit system config;}) // {inherit (inputs.nixpkgs) sourceInfo;};
        }
      );
      loadCellFor = cellName: let
        cPath = paths.cellPath cellsFrom cellName;
        loadCellBlock = cellBlock: let
          oPath = paths.cellBlockPath cPath cellBlock;
          # extractor instatiates actions and extracts metadata for the __std registry
          extract = name: target: let
            tPath = paths.targetPath oPath name;
            targetFragment = ''"${system}"."${cellName}"."${cellBlock.name}"."${name}"'';
            actionFragment = action: {
              actionFragment = ''"__std"."actions"."${system}"."${cellName}"."${cellBlock.name}"."${name}"."${action}'';
            };
            actions =
              if cellBlock ? actions
              then
                (
                  if
                    l.trivial.functionArgs
                    == {
                      system = false;
                      flake = false;
                      fragment = false;
                      fragmentRelPath = false;
                    }
                  then
                    # warnOldActionInterface
                    cellBlock.actions {
                      inherit system;
                      flake = inputs.self.sourceInfo.outPath;
                      fragment = targetFragment;
                      fragmentRelPath = "${cellName}/${cellBlock.name}/${name}";
                    }
                  else
                    cellBlock.actions {
                      inherit system;
                      fragment = targetFragment;
                      fragmentRelPath = "${cellName}/${cellBlock.name}/${name}";
                      target = res.output.${cellBlock.name}.${name};
                    }
                )
              else [];
            ci =
              if cellBlock ? ci
              then
                l.mapAttrsToList (action: _:
                  if ! l.any (a: a.name == action) actions
                  then
                    throw ''
                      divnix/std(ci-integration): Block Type '${cellBlock.type}' has no '${action}' Action defined.
                      ---
                      ${l.generators.toPretty {} (l.removeAttrs cellBlock ["__functor"])}
                    ''
                  else {
                    inherit name;
                    cell = cellName;
                    block = cellBlock.name;
                    blockType = cellBlock.type;
                    inherit action;
                    inherit targetFragment;
                    inherit (actionFragment action) actionFragment;
                  })
                cellBlock.ci
              else [];
            ci' = let
              f = set: let
                action = inputs.self.__std.actions.${system}.${set.cell}.${set.block}.${set.name}.${set.action} or null;
              in
                set
                // {
                  targetDrv = action.targetDrv or (inputs.self.${system}.${set.cell}.${set.block}.${set.name}.drvPath or null);
                  actionDrv = action.drvPath or null;
                }
                // (
                  if action ? proviso
                  then {inherit (action) proviso;}
                  else {}
                );
            in
              map f ci;
          in {
            inherit ci ci';
            actions = {
              inherit name;
              value = l.listToAttrs (map (a: {
                  inherit (a) name;
                  value = validate.ActionCommand a.command;
                })
                actions);
            };
            init = {
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
          };
          isFile = l.pathExists oPath.file;
          isDir = l.pathExists oPath.dir;
          import' = path: let
            # since we're not really importing files within the framework
            # the non-memoization of scopedImport doesn't have practical penalty
            block = validate.BlockSignature path (l.scopedImport signature path);
            signature = args // {cell = res.output;}; # recursion on cell
          in
            if l.typeOf block == "set"
            then block
            else block signature;
          imported =
            if isFile
            then validate.Import cellBlock.type oPath.file (import' oPath.file)
            else if isDir
            then validate.Import cellBlock.type oPath.dir (import' oPath.dir)
            else throw "unreachable!";
          extracted = l.mapAttrsToList extract imported;
        in
          optionalLoad (isFile || isDir)
          [
            # top level output
            {${cellBlock.name} = imported;}
            # __std.actions (slow)
            {${cellBlock.name} = l.listToAttrs (map (x: x.actions) extracted);}
            # __std.init (fast)
            {
              cellBlock = cellBlock.name;
              blockType = cellBlock.type;
              readme =
                if l.pathExists oPath.readme
                then oPath.readme
                else "";
              targets = map (x: x.init) extracted;
            }
            # __std.ci
            {
              ci = map (x: x.ci) extracted;
            }
            # __std.ci'
            {
              ci' = map (x: x.ci') extracted;
            }
          ];
        res = accumulate (l.map loadCellBlock CellBlocks);
      in
        optionalLoad (res != {})
        [
          # top level output
          {${cellName} = res.output;}
          # __std.actions (slow)
          {${cellName} = res.actions;}
          # __std.init (fast)
          {
            cell = cellName;
            readme =
              if l.pathExists cPath.readme
              then cPath.readme
              else "";
            cellBlocks = res.init; # []
          }
          # __std.ci
          {
            inherit (res) ci;
          }
          # __std.ci'
          {
            inherit (res) ci';
          }
        ]; # };
      res = accumulate (l.map loadCellFor Cells);
    in
      optionalLoad (res != {})
      [
        # top level output
        {${system} = res.output;}
        # __std.actions (slow)
        {${system} = res.actions;}
        # __std.init (fast)
        {
          name = system;
          value = res.init;
        }
        # __std.ci
        {
          ci = [
            {
              name = system;
              value = res.ci;
            }
          ];
        }
        # __std.ci'
        {
          ci' = [
            {
              name = system;
              value = res.ci';
            }
          ];
        }
      ];
    res = accumulate (l.map loadOutputFor Systems);
  in
    res.output
    // {
      __std.ci = l.listToAttrs res.ci;
      __std.ci' = l.listToAttrs res.ci';
      __std.init = l.listToAttrs res.init;
      __std.actions = res.actions;
      __std.direnv_lib = ../direnv_lib.sh;
      __std.nixConfig = let
        # FIXME: refactor when merged NixOS/nixpkgs#203999
        nixConfig = l.generators.toKeyValue {
          mkKeyValue = l.generators.mkKeyValueDefault {
            mkValueString = v:
              if l.isList v
              then l.concatStringsSep " " v
              else if (l.isPath v || v ? __toString)
              then toString v
              else l.generators.mkValueStringDefault {} v;
          } " = ";
        };
      in
        nixConfig (import "${inputs.self}/flake.nix").nixConfig or {};
    };
in
  grow
