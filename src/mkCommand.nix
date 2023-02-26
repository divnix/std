{nixpkgs}: let
  mkCommand = currentSystem: args: let
    inherit (nixpkgs.legacyPackages.${currentSystem}) pkgs;
  in
    args
    // {
      command = pkgs.writeShellScript "${args.name}" args.command;
    };
in
  mkCommand
