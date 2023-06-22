{std}: let
  # augmented std from the local cell
  inherit (std.lib) cfg dev;
in
  builtins.mapAttrs (
    n: v:
      (
        # render base implementation
        (dev.mkNixago v)
        # extend via functor with no data
        {
          data =
            {
              conform = {};
              just = {
                tasks = {};
              };
            }
            .${n}
            or {};
        }
      )
      .configFile
  )
  cfg
