/*
This file holds reproducible shells with commands in them.

They conveniently also generate config files in their startup hook.
*/
{
  # Tool Homepage: https://numtide.github.io/devshell/
  default = inputs.std.lib.dev.mkShell {
    name = "CONFIGURE-ME";

    # Tool Homepage: https://nix-community.github.io/nixago/
    # This is Standard's devshell integration.
    # It runs the startup hook when entering the shell.
    nixago = [
      inputs.std.std.nixago.conform
      (inputs.std.std.nixago.treefmt cell.config.treefmt)
      (inputs.std.std.nixago.editorconfig cell.config.editorconfig)
      (inputs.std.std.nixago.githubsettings cell.config.githubsettings)
      (inputs.std.std.nixago.lefthook cell.config.lefthook)
      (inputs.std.std.nixago.mdbook cell.config.mdbook)
    ];

    commands = [
      {
        category = "rendering";
        package = inputs.nixpkgs.mdbook;
      }
    ];
  };
}
