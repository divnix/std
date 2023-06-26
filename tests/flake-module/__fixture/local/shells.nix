let
  inherit (inputs.std) lib;
in {
  default = lib.dev.mkShell ({...}: {
    name = "test-shell";
  });
}
