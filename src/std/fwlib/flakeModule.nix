{
  root,
  paisano,
  nixpkgs,
  yants,
}: let
  l = nixpkgs.lib // builtins;
  inherit (paisano) harvest pick winnow;
  inherit (root) grow;
  types = import (paisano + /types/default.nix) {
    inherit l yants;
    paths = null;
  };
in
  {
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
        (with lib.types; (either
          (listOf nonEmptyStr)
          (listOf (listOf nonEmptyStr))))
        check
        ;
    };

    cellBlocksType = mkOptionType {
      name = "cellBlocks";
      description = "list of cell block";
      descriptionClass = "noun";
      inherit
        (types.BlockTypes
          "Block Types usable in the Standard flake-parts module")
        check
        ;
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
          type = lib.types.submodule {
            options = {
              cellsFrom = mkOption {
                description = "Where Standard discovers Cells from.";
                type = with lib.types; path;
                example = literalExpression "./nix";
              };
              cellBlocks = mkOption {
                description = "Declaration of all Cell Blocks used in the project.";
                type = cellBlocksType;
                example = literalExpression ''
                  with std.blockTypes; [
                    (installables "packages" {ci.build = true;})
                    (devshells "shells" {ci.build = true;})
                    (containers "containers" {ci.publish = true;})
                  ]
                '';
              };
              nixpkgsConfig = mkOption {
                description = "Nixpkgs configuration applied to `inputs.nixpkgs` (if that input exists).";
                type = with lib.types; attrs;
                default = {};
                example = literalExpression ''
                  { allowUnfree = true; }
                '';
              };
            };
          };
        };
        pick = mkOption {
          description = "Pick Standard outputs. Like `harvest` but remove the system for outputs that are system agnostic.";
          type = with lib.types; attrsOf harvesterType;
          example = literalExpression ''
            {
              lib = [ "utils" "library" ];
            }
          '';
        };
        winnowIf = mkOption {
          description = "Set the predicates for `winnow`.";
          type = with lib.types; attrsOf (functionTo (functionTo bool));
          example = literalExpression ''
            {
              packages = n: v: n == "foo";
            }
          '';
        };
        winnow = mkOption {
          description = "Winnow Standard outputs. Like `harvest`, but with filters from the predicates of `winnowIf`.";
          type = with lib.types; attrsOf harvesterType;
          example = literalExpression ''
            {
              packages = [ "app3" "packages" ];
            }
          '';
        };
        harvest = mkOption {
          description = "Harvest Standard outputs into a Nix-CLI-compatible form (a.k.a. the 'official' flake schema).";
          type = with lib.types; attrsOf harvesterType;
          example = literalExpression ''
            {
              devShells = [ "toolchain" "shells" ];
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
        grown = grow {
          inherit inputs;
          inherit (config) systems;
          # access them explicitly to trigger a module system error if not defined
          inherit (cfg.grow) cellsFrom cellBlocks nixpkgsConfig;
        };
        picked = mapAttrs (_: v: pick grown v) cfg.pick;
        harvested = mapAttrs (_: v: harvest grown v) cfg.harvest;
        winnowed = zipAttrsWith (n: v: winnow (head v) grown (head (tail v))) [cfg.winnowIf cfg.winnow];
      in
        lib.mkIf (opt.grow.isDefined) (
          lib.foldl' lib.recursiveUpdate {} (
            [grown]
            ++ (lib.optionals opt.pick.isDefined [picked])
            ++ (lib.optionals (opt.winnow.isDefined && opt.winnowIf.isDefined) [winnowed])
            ++ (lib.optionals opt.harvest.isDefined [harvested])
          )
        );

      # exposes the raw scheme of the std layout inside flake-parts
      perInput = system: flake: {cells = flake.${system} or {};};
    };
  }
