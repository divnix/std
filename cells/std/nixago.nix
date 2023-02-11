{
  inputs,
  cell,
}: let
  inherit (import (inputs.self + /deprecation.nix) inputs) warnNixagoMoved;
in
  builtins.mapAttrs (_: warnNixagoMoved) {
    inherit
      (inputs.cells.lib.cfg)
      adrgen
      editorconfig
      conform
      just
      lefthook
      mdbook
      treefmt
      githubsettings
      ;
  }
