inputs: let
  removeBy = import ./cells/std/errors/removeBy.nix {inherit inputs;};
in {
  warnOldActionInterface = actions:
    removeBy "March 2023" ''

      The action interface has chaged from:
        { system, flake, fragment, fragmentRelPath }
      To:
        { system, target, fragment, fragmentRelPath }

      Please adjust the following actions:

      ${builtins.concatStringsSep "\n" (map (a: " - ${a.name}: ${(builtins.unsafeGetAttrPos "name" a).file}") actions)}
    '';

  warnNixagoOutfactored = removeBy "May 2023" ''

    std.presets.nixago has been outfactored into its own repository.

    Add to your flake.nix

    inputs.std-data-collection.url = "github:divnix/std-data-collection";
    inputs.std-data-collection.inputs.std.follows = "std";
    inputs.std-data-collection.inputs.nixpkgs.follows = "nixpkgs";

    Replace accessors of
      `inputs.std.presets.nixago`
    with
      `inputs.std-data-collection.data.configs`
  '';

  warnNixagoMoved = removeBy "May 2023" ''

    In order to improve semantic clarity,
    std.std.nixago has been moved to std.lib.configs.

    Replace accessors of
      `inputs.std.std.nixago`
    with
      `inputs.std.lib.cfg`
  '';
}
