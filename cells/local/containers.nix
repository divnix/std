{
  inputs,
  scope,
}: let
  inherit (inputs) nixpkgs;
  inherit (inputs.cells) lib;
  l = nixpkgs.lib // builtins;
in {
  dev = lib.ops.mkDevOCI {
    name = "docker.io/std-dev";
    tag = "latest";
    devshell = scope.devshells.default;
    labels = {
      title = "std-dev";
      version = "0.1.0";
      url = "https://github.com/divnix";
      source = "https://github.com/divnix";
      description = ''
        A prepackaged container for hacking on std
      '';
    };
  };
  vscode = lib.ops.mkDevOCI {
    name = "docker.io/std-vscode";
    tag = "latest";
    devshell = scope.devshells.default;
    vscode = true;
    labels = {
      title = "std-dev";
      version = "0.1.0";
      url = "https://github.com/divnix";
      source = "https://github.com/divnix";
      description = ''
        A prepackaged vscode devcontainer for hacking on std
      '';
    };
  };
}
