{inputs}: input: url: target: let
  l = inputs.nixpkgs.lib // builtins;

  condition = l.hasAttr input inputs;
  trace = l.traceSeqN 1 inputs;
in
  assert l.assertMsg condition (trace ''

    ===============================================
    !!!  🚜️   STANDARD INPUT OVERLOADING   🚜️   !!!
    -----------------------------------------------
    In order to be able to use this target, an
    extra input must be overloaded onto Standard
    -----------------------------------------------
    Target:      ${target}
    Extra Input: ${input}
    Url:         ${url}
    -----------------------------------------------
    To fix this, add this to your './flake.nix':

      inputs.std.inputs.${input}.url =
        "${url}";

    For reference, see current inputs to Standard
    in the above trace.
    ===============================================

    🔥 🔥 🔥 🔥 🔥 🔥 🔥 🔥 🔥 🔥 🔥 🔥 🔥 🔥 🔥 🔥



  ''); inputs
