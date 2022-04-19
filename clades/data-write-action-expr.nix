let
  pkgs =
    (builtins.getFlake "${nixpkgs.sourceInfo.outPath}")
    .legacyPackages
    .${builtins.currentSystem};
  this =
    (builtins.getFlake "${flake.sourceInfo.outPath}")
    ."${fragment}";
in
  pkgs.writeTextFile {
    name = "data-clade-write";
    text = builtins.toJSON this;
    executable = false;
    destination = "/data";
  }
