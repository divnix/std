let
  inherit (inputs) namaka self;
  inputs' = builtins.removeAttrs inputs ["self"];
in {
  snapshots = {
    meta.description = "The main Standard Snapshotting test suite";
    check = namaka.lib.load {
      src = self + /tests;
      inputs = inputs' // {inputs = inputs';};
    };
  };
}
