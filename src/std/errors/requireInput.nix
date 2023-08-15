{inputs}: input: url: target: let
  l = inputs.nixpkgs.lib // builtins;

  # other than `divnix/blank`
  isBlank = input: inputs.${input}.narHash == "sha256-O8/MWsPBGhhyPoPLHZAuoZiiHo9q6FLlEeIDEXuj6T4=";

  ansi = import ./ansi.nix;

  pad = n: s: let
    prefix = l.concatStringsSep "" (l.genList (_: " ") n);
  in
    prefix + s;

  indent = s: let
    n = 5;
    prefix = l.concatStringsSep "" (l.genList (_: " ") n);
    lines = l.splitString "\n" s;
  in
    l.concatStringsSep "\n${prefix}│ " lines;

  warn = let
    apply =
      l.replaceStrings
      (map (key: "{${key}}") (l.attrNames ansi))
      (l.attrValues ansi);
  in
    msg: l.trace (apply "🚀 {bold}{200}Standard Input Overloading{reset}${msg}") "";

  body = ''
    In order to use ${target}, add to {bold}flake.nix{un-bold}:

      inputs.std.inputs.${input}.url =
        "${url}";
  '';

  inputs' = let
    names = l.attrNames (l.removeAttrs inputs ["self" "cells" "blank" "nixpkgs"]);
    nameLengths = map l.stringLength names;
    maxNameLength =
      l.foldl'
      (max: v:
        if v > max
        then v
        else max)
      0
      nameLengths;

    lines =
      l.map (
        name: "- ${name}${
          if isBlank name
          then pad (maxNameLength - (l.stringLength name)) " | blanked out"
          else ""
        }"
      )
      names;
  in
    "Declared Inputs:\n" + (l.concatStringsSep "\n" lines);
in
  assert l.assertMsg (! (isBlank input)) (warn ''

    ─────┬─────────────────────────────────────────────────────────────────────────
      🏗️  │ {bold}Input Overloading for ${target}{un-bold}
    ─────┼─────────────────────────────────────────────────────────────────────────
      📝 │ {italic}${indent body}{un-italic}
    ─────┴─────────────────────────────────────────────────────────────────────────
      🙋   ${indent inputs'}
    ───────────────────────────────────────────────────────────────────────────────
  ''); inputs
