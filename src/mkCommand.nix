{nixpkgs}: let
  writeShellScript = system: nixpkgs.legacyPackages.${system}.writeShellScript;
  mkCommand = system: args: args // {command = writeShellScript system "${args.name}" args.command;};
in
  mkCommand
