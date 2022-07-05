let
  l = builtins;
  /*
  A helper function which hides the complexities of dealing
  with 'system' properly from you, while still providing
  escape hatches when dealing with cross-compilation.

  You can use this function independently of the rest of std.
  */
  deSystemize = let
    iteration = cutoff: system: fragment:
      if ! (l.isAttrs fragment) || cutoff == 0
      then fragment
      else if l.hasAttr "${system}" fragment && ! l.isFunction fragment.${system}
      then fragment // fragment.${system}
      else if l.hasAttr "${system}" fragment && l.isFunction fragment.${system}
      then fragment // {__functor = _: fragment.${system};}
      else l.mapAttrs (_: iteration (cutoff - 1) system) fragment;
  in
    iteration 3;
in
  deSystemize
