let
  inherit (inputs) namaka self;
  inputs' = builtins.removeAttrs inputs ["self"];
in {
  inherit inputs;
  snapshots = {
    meta.description = "The main Standard Snapshotting test suite";
    check = namaka.lib.load {
      src = self + /tests;
      inputs =
        inputs'
        //
        # inputs.self is too noisy for 'check-augmented-cell-inputs'
        {inputs = inputs';};
    };
  };
}
