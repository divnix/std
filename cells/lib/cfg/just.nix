{
  inputs,
  scope,
}: let
  inherit (inputs) nixpkgs;
  l = nixpkgs.lib // builtins;
in
  inputs.cells.lib.dev.mkNixago {
    data = {};
    apply = d: let
      # Transforms interpreter attribute if present
      # nixpkgs.pkgname -> nixpkgs.pkgname + '/bin/<name>'
      getExe = x: "${l.getBin x}/bin/${x.meta.mainProgram or (l.getName x)}";
      final =
        d
        // {
          tasks =
            l.mapAttrs
            (n: v:
              v // l.optionalAttrs (v ? interpreter) {interpreter = getExe v.interpreter;})
            d.tasks;
        };
    in {
      data = final; # CUE expects structure to be wrapped with "data"
    };
    format = "text";
    output = "Justfile";
    packages = [nixpkgs.just];
    hook = {
      mode = "copy";
    };
    engine = inputs.nixago.engines.cue {
      files = [./just.cue];
      flags = {
        expression = "rendered";
        out = "text";
      };
      postHook = ''
        ${l.getExe nixpkgs.just} --unstable --fmt -f $out
      '';
    };
  }
