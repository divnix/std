let
  l = builtins;
  /*
   A helper function which hides the complexities of dealing
   with 'system' properly from you, while still providing
   escape hatches when dealing with cross-compilation.
   
   You can use this function independently of the rest of std.
   */
  deSystemize = system: fragment:
    if l.isAttrs fragment && l.hasAttr "${system}" fragment
    then fragment // fragment.${system}
    else
      l.mapAttrs (
        # _ consumes input's name
        # fragment -> maybe systems
        _: fragment:
          if l.isAttrs fragment && l.hasAttr "${system}" fragment
          then fragment // fragment.${system}
          else
            l.mapAttrs (
              # _ consumes input's output's name
              # fragment -> maybe systems
              _: fragment:
                if l.isAttrs fragment && l.hasAttr "${system}" fragment
                then (fragment // fragment.${system})
                else fragment
            )
            fragment
      )
      fragment;
in
  deSystemize
