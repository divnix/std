fragment: {
  name = "build";
  description = "build this target";
  command = ''
    nix build "$PRJ_ROOT#${fragment}
  '';
}
