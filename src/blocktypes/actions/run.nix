{
  lib,
  target,
}: let
  name = lib.removeSuffix "-${target.version or ""}" target.name;

  programName =
    target.meta.mainProgram
    or target.pname
    or name;

  run =
    # this is the exact sequence mentioned by the `nix run` docs
    # and so should be compatible
    target.program
    or "${target}/bin/${programName}";
in
  run
