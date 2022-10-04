{inputs}: time: body: let
  l = inputs.nixpkgs.lib // builtins;
  pad = l.concatStringsSep "" (l.genList (_: " ") (21 - (l.stringLength time)));
in
  l.warn ''


    ===============================================
    !!!  🔥️  STANDARD DEPRECATION WARNING  🔥️   !!!
    -----------------------------------------------
    !!! Action required until scheduled removal !!!
    !!! Sheduled Removal: ${pad}${time} !!!
    -----------------------------------------------
    On schedule, deprecated facilities will be
    removed from Standard without further warning.
    -----------------------------------------------
    ${body}
    ===============================================

    ⏳ ⏳ ⏳ ⏳ ⏳ ⏳ ⏳ ⏳ ⏳ ⏳ ⏳ ⏳ ⏳ ⏳ ⏳ ⏳



  ''
