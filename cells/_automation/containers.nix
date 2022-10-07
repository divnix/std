{ inputs
, cell
}:
let
  inherit (inputs.cells) nixpkgs lib;
  l = nixpkgs.lib // builtins;
in
{
  dev = lib.ops.mkDevOCI {
    name = "docker.io/std-dev";
    tag = "latest";
    devshell = inputs.cells._automation.devshells.default;
    labels = {
      title = "std-dev";
      version = "0.1.0";
      url = "https://github.com/divnix";
      source = "https://github.com/divnix";
      description = ''
        A prepackaged devcontainer for hacking on std
      '';
    };
  };
}
