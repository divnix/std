{nixpkgs}: let
  writeShellScript = currentSystem: nixpkgs.legacyPackages.${currentSystem}.writeShellScript;
  mkCommand = currentSystem: args: args // {command = writeShellScript currentSystem "${args.name}" args.command;};
in
  mkCommand
