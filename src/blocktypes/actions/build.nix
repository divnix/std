drv: {
  name = "build";
  description = "build this target";
  command = ''
    # ${drv}
    nix build ${builtins.unsafeDiscardStringContext drv.drvPath}
  '';
}
