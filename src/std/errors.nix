{
  inputs,
  cell,
}: {
  requireInput = import ./errors/requireInput.nix {inherit inputs;};
  # beware: this is also "manually" imported from top level ./deprecation.nix
  removeBy = import ./errors/removeBy.nix {inherit inputs;};
}
