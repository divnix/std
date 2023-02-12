# Ansi escape codes
let
  # Nix strings only support \t, \r and \n as escape codes, so actually store
  # the literal escape "ESC" code.
  inherit (builtins) foldl' genList;
  esc = "";
in
  {
    reset = "${esc}[0m";
    bold = "${esc}[1m";
    un-bold = "${esc}[21m";
    italic = "${esc}[3m";
    un-italic = "${esc}[23m";
    underline = "${esc}[4m";
    un-underline = "${esc}[24m";
  }
  // (foldl' (x: y: x // {"${toString y}" = "${esc}[38;5;${toString y}m";}) {} (genList (x: x) 256))
