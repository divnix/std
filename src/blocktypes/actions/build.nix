flake: fragment: {
  name = "build";
  description = "build this target";
  command = ''
    nix build ${flake}#${fragment}
  '';
}
