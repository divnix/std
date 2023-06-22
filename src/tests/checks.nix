let
  inherit (inputs) namaka self;
in {
  inherit inputs;
  snapshots = namaka.lib.load {
    src = self + /tests;
    inputs = builtins.removeAttrs inputs ["self"];
  };
}
