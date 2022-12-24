{
  validators,
  grow,
  pick,
  winnow,
  harvest,
}: {
  inputs,
  config,
  options,
  lib,
  ...
}: let
  inherit
    (builtins)
    all
    concatMap
    head
    isList
    length
    mapAttrs
    tail
    zipAttrsWith
    ;
  inherit
    (lib)
    getValues
    mkOption
    mkOptionType
    showDefs
    showOption
    types
    literalExpression
    ;

  # ensures we always end up with a list of lists
  # if more than one definition
  mergeHarvesterOption = loc: defs: let
    list = getValues defs;
  in
    if length list == 1
    then head list
    else if all isList list
    then
      concatMap (l:
        if isList l
        then l
        else [l])
      list
    else throw "Cannot merge definitions of `${showOption loc}', as at least one merge candidate is not a list of strings or a list of list of strings. Definition values:${showDefs defs}";

  harvesterType = mkOptionType {
    name = "harvester";
    description = "harvest path(s) as a list of strings or a list of lists of strings";
    descriptionClass = "noun";
    merge = mergeHarvesterOption;
    emptyValue = {value = [];};
    inherit
      (types.either
        (types.listOf types.nonEmptyStr)
        (types.listOf (types.listOf types.nonEmptyStr)))
      check
      ;
  };

  cellBlocksType = mkOptionType {
    name = "cellBlocks";
    description = "list of cell block";
    descriptionClass = "noun";
    inherit (validators.CellBlocks) check;
  };

  opt = options.std;
  cfg = config.std;
in {
  _file = ./flakeModule.nix;
  options = {
    std = {
      grow = mkOption {
        description = ''
          Orderly 'grow' a project from Standard Cells & Cell Blocks.
           - Find the [glossary here](https://std.divnix.com/glossary.html).
           - Find a good [walk-through here](https://jmgilman.github.io/std-book/).
           - And the general [documentation here](https://std.divnix.com/index.html).
        '';
        type = types.submodule {
          options = {
            cellsFrom = mkOption {
              description = "Where Standard discovers Cells from.";
              type = types.path;
              example = literalExpression "./nix";
            };
            cellBlocks = mkOption {
              description = "Declaration of all Cell Blocks used in the project.";
              type = cellBlocksType;
              example = literalExpression ''
                with std.blockTypes; [
                  (installables "packages" {ci.build = true;})
                  (devshells "devshells" {ci.build = true;})
                  (containers "containers" {ci.publish = true;})
                ]
              '';
            };
            nixpkgsConfig = mkOption {
              description = "Nixpkgs configuration applied to `inputs.nixpkgs` (if that input exists).";
              type = types.attrs;
              example = literalExpression ''
                { allowUnfree = true; }
              '';
            };
          };
        };
      };
      pick = mkOption {
        description = "Pick Standard outputs. Like `harvest` but remove the system for outputs that are system agnostic.";
        type = types.attrsOf harvesterType;
        example = literalExpression ''
          {
            lib = [ "utils" "library" ];
          }
        '';
      };
      winnowIf = mkOption {
        description = "Set the predicates for `winnow`.";
        type = types.attrsOf (types.functionTo (types.functionTo types.bool));
        example = literalExpression ''
          {
            packages = n: v: n == "foo";
          }
        '';
      };
      winnow = mkOption {
        description = "Winnow Standard outputs. Like `harvest`, but with filters from the predicates of `winnowIf`.";
        type = types.attrsOf harvesterType;
        example = literalExpression ''
          {
            packages = [ "app3" "packages" ];
          }
        '';
      };
      harvest = mkOption {
        description = "Harvest Standard outputs into a Nix-CLI-compatible form (a.k.a. the 'official' flake schema).";
        type = types.attrsOf harvesterType;
        example = literalExpression ''
          {
            devShells = [ "toolchain" "devshells" ];
            packages = [
              # a list of lists can "harvest" from multiple cells
              [ "app1" "packages" ]
              [ "app2" "packages" ]
            ];
          }
        '';
      };
    };
  };
  config = {
    flake = let
      grown = grow (cfg.grow
        // {
          inherit inputs;
          inherit (config) systems;
          # access them explicitly to trigger a module system error if not defined
          inherit (cfg.grow) cellsFrom cellBlocks;
        });
      picked = mapAttrs (_: v: pick grown v) cfg.pick;
      harvested = mapAttrs (_: v: harvest grown v) cfg.harvest;
      winnowed = zipAttrsWith (n: v: winnow (head v) grown (head (tail v))) [cfg.winnowIf cfg.winnow];
    in
      lib.foldl' lib.recursiveUpdate {} (
        [grown]
        ++ (lib.optionals opt.pick.isDefined [picked])
        ++ (lib.optionals (opt.winnow.isDefined && opt.winnowIf.isDefined) [winnowed])
        ++ (lib.optionals opt.harvest.isDefined [harvested])
      );

    # exposes the raw scheme of the std layout inside flake-parts
    perInput = system: flake: {cells = flake.${system} or {};};
  };
}
