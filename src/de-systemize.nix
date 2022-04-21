system: fragment: let
  l = builtins;
in
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
    fragment
