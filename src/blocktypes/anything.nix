{
  nixpkgs,
  mkCommand,
}: let
  l = nixpkgs.lib // builtins;
  /*
  Use the Anything Blocktype as a fallback.

  It doesn't have actions.
  */
  anything = name: {
    inherit name;
    type = "anything";
  };
in
  anything
