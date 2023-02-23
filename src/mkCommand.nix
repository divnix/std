{nixpkgs}: let
  mkCommand = system: args: let
    inherit (nixpkgs.legacyPackages.${system}) pkgs;
  in
    args
    // {
      command = (pkgs.writeShellScript "${args.name}" args.command).overrideAttrs (_:
        pkgs.lib.optionalAttrs (args ? provisory) {
          __provisory = builtins.unsafeDiscardStringContext args.provisory;
        });
    };
in
  mkCommand
