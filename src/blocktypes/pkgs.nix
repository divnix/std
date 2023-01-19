{...}: let
  /*
  Use the Pkgs Blocktype if you need to construct your custom
  variant of nixpkgs with overlays.

  Targets will be excluded from the CLI / TUI  and thus not
  slow them down.
  */
  pkgs = name: {
    inherit name;
    type = "pkgs";
    cli = false; # its special power
  };
in
  pkgs
