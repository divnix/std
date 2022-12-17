writeShellScriptWithPrjRoot: fragment: {
  name = "build";
  description = "build this target";
  command = writeShellScriptWithPrjRoot "build" ''
    nix build "$PRJ_ROOT#${fragment}
  '';
}
