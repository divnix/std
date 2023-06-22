# This Cell Block is the framework lib. It is special.
# To make use of `std` inside `std`, it is bootsrapped separately.
{
  # during bootstrap: no .cells  / don't use
  # during bootstrap: no input is deSystemized
  inputs,
  # during bootstrap: set to {}  / don't use
  cell,
}: let
  inherit (inputs) haumea paisano self;
  fwlib = haumea.lib.load {
    src = ./fwlib;
    inputs = removeAttrs inputs ["self"];
  };
in
  fwlib
  // rec {
    grow = args: removeAttrs (growOn args) ["__functor"];
    growOn = {
      cellBlocks ? [
        (fwlib.blockTypes.functions "library")
        (fwlib.blockTypes.runnables "apps")
        (fwlib.blockTypes.installables "packages")
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
      paisano.growOn args';
  }
