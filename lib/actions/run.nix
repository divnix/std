{
  nixpkgs,
  root,
  super,
}: let
  inherit (root) mkCommand;
  inherit (super) contextFreeDrv;
  inherit (nixpkgs.lib) getName;
  # this is the exact sequence mentioned by the `nix run` docs
  # and so should be compatible
in
  currentSystem: target: let
    programName = target.meta.mainProgram or (getName target);
  in
    mkCommand currentSystem "run" "run it" ''${target.program or "${target}/bin/${programName}"} "$@" '' {}
