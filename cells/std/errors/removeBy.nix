{inputs}: time: body: let
  l = inputs.nixpkgs.lib // builtins;
  ansi = import ./ansi.nix;
  pad = s: let
    n = 17;
    prefix = l.concatStringsSep "" (l.genList (_: " ") (n - (l.stringLength s)));
  in
    prefix + s;
  indent = s: let
    n = 5;
    prefix = l.concatStringsSep "" (l.genList (_: " ") n);
    lines = l.splitString "\n" s;
  in
    "  📝 │ " + (l.concatStringsSep "\n${prefix}│ " lines);
  warn = let
    apply =
      l.replaceStrings
      (map (key: "{${key}}") (l.attrNames ansi))
      (l.attrValues ansi);
  in
    msg:
      l.trace (apply "🔥 {bold}{196}Standard Deprecation Notices - {220}run `std check' to show!{reset}")
      l.traceVerbose (apply "\n{202}${msg}{reset}");
in
  warn ''
    ─────┬─────────────────────────────────────────────────────────────────────────
      💪 │ {bold}Action Required !{un-bold}
    ─────┼─────────────────────────────────────────────────────────────────────────
    {italic}${indent body}{un-italic}
    ─────┼─────────────────────────────────────────────────────────────────────────
      📅 │ {bold}Scheduled Removal: ${pad time}{un-bold}
    ─────┴─────────────────────────────────────────────────────────────────────────
  ''
