{inputs}: time: body: let
  l = inputs.nixpkgs.lib // builtins;
  pad = l.concatStringsSep "" (l.genList (_: " ") (20 - (l.stringLength time)));
in
  l.warn ''


    ===============================================
    !!!  🔥️  STANDARD DEPRECATION WARNING  🔥️   !!!
    -----------------------------------------------
    !!! Action required until scheduled removal !!!
    !!! Scheduled Removal: ${pad}${time} !!!
    -----------------------------------------------
    On schedule, deprecated facilities will be
    removed from Standard without further warning.
    -----------------------------------------------
    ${body}
    ===============================================

    ⏳ ⏳ ⏳ ⏳ ⏳ ⏳ ⏳ ⏳ ⏳ ⏳ ⏳ ⏳ ⏳ ⏳ ⏳ ⏳



  ''
