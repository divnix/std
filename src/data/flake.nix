{
  inputs = {
    # injected (private) inputs
    mdbook-paisano-preprocessor.url = "github:paisano-nix/mdbook-paisano-preprocessor";
    mdbook-paisano-preprocessor.inputs.nixago.follows = "";
    mdbook-paisano-preprocessor.inputs.devshell.follows = "";
  };
  outputs = i: i;
}
