{
  lib,
  target,
}: let
  name = lib.getName;

  programName =
    target.meta.mainProgram
    or (lib.getName target);

  run =
    # this is the exact sequence mentioned by the `nix run` docs
    # and so should be compatible
    target.program
    or "${target}/bin/${programName}";
in
  run
