{
  paisano,
  root,
}: let
  inherit (root) blockTypes;
in
  {
    cellBlocks ? [
      (blockTypes.functions "library")
      (blockTypes.runnables "apps")
      (blockTypes.installables "packages")
    ],
    ...
  } @ args: let
    # preserve pos of `cellBlocks` if not using the default
    args' =
      args
      // (
        if args ? cellBlocks
        then {}
        else {inherit cellBlocks;}
      );
  in
    paisano.growOn args' {
      # standard-specific quality-of-life assets
      __std.direnv_lib = ./direnv_lib.sh;
    }
