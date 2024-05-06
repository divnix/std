let
  inherit (inputs.cells.std.errors) requireInput;
  inherit (requireInput "arion" "github:hercules-ci/arion" "std.lib.dev.mkArion") arion nixpkgs;

  inherit (nixpkgs) lib;

  disabledNotice = ''
    divnix/std disabled arion's nixos instrumentation.

    Standard being the horizontal integration layer it would be a layer violation
    to delegate integration to a commissioned tool.

    Doing this would reduce the mental clarity of std since a foreign integration
    pattern would have to be supported.

    If you want to create a container that uses NixOS + systemd as its init-system,
    please find out how it's done here:
      ${arion}/src/nix/service/nixos-init.nix

    You can then use the normal container block type to create your image and
    pass it to your arion configuration.
  '';

  disableNixosModule = {
    disabledModules = [
      (arion + /src/nix/nixos/container-systemd.nix)
      (arion + /src/nix/nixos/default-shell.nix)
      (arion + /src/nix/service/nixos.nix)
      (arion + /src/nix/service/nixos-init.nix)
    ];
    imports = [
      (lib.mkRemovedOptionModule ["nixos" "configuration"] disabledNotice)
      (lib.mkRemovedOptionModule ["nixos" "build"] disabledNotice)
      (lib.mkRemovedOptionModule ["nixos" "evaluatedConfig"] disabledNotice)
    ];
  };
in
  module:
    arion.lib.eval {
      modules = [disableNixosModule module];
      pkgs = nixpkgs;
    }
