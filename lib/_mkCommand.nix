{nixpkgs}: currentSystem: name: description: command: args: let
  inherit (nixpkgs.legacyPackages.${currentSystem}) pkgs;
in
  args
  // {
    inherit name description;
    command = pkgs.writeShellScript "${name}" command;
  }
