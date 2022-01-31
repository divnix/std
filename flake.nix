{
  description = "The Nix Flakes framework for perfectionists with deadlines";
  # override downstream with inputs.std.inputs.nixpkgs.follows = ...
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  inputs.devshell.url = "github:numtide/devshell";
  inputs.treefmt.url = "github:numtide/treefmt";
  inputs.treefmt.inputs.nixpkgs.follows = "nixpkgs";
  inputs.alejandra.url = "github:kamadorueda/alejandra";
  inputs.alejandra.inputs.nixpkgs.follows = "nixpkgs";
  outputs =
    { nixpkgs
    , devshell
    , treefmt
    , alejandra
    , ...
    }
    @ inputs:
    let
      validate = import ./validators.nix { inherit inputs organelleName organellePaths; };
      # organelleName is constructed from the singleton name if defined, else form the plural
      organelleName = organelle: organelle.m or organelle.o;
      # organellePaths are constructed from the specified organelles
      organellePaths =
        cellsFrom:
        cell:
        organelle:
        (if organelle ? o then { onePath = "${ cellsFrom }/${ cell }/${ organelle.o }.nix"; } else { })
          // (if organelle ? m then { manyPath = "${ cellsFrom }/${ cell }/${ organelle.m }.nix"; } else { });
      runnables = attrs: validate.Organelle (attrs // { clade = "runnables"; });
      installables = attrs: validate.Organelle (attrs // { clade = "installables"; });
      functions = attrs: validate.Organelle (attrs // { clade = "functions"; });
      grow =
        let
          defaultSystems =
            nixpkgs.lib.attrsets.cartesianProductOfSets
              {
                build = [
                  "x86_64-apple-darwin"
                  "x86_64-unknown-linux-gnu"
                  "aarch64-apple-darwin"
                  "aarch64-unknown-linux-gnu"
                ];
                host = builtins.attrNames inputs.self.systems;
              };
        in
          { inputs
          , cellsFrom
          , organelles ? [
              {
                o = "function";
                m = "functions";
                clade = "functions";
              }
              {
                o = "app";
                m = "apps";
                clade = "runnables";
              }
              {
                o = "package";
                m = "packages";
                clade = "installables";
              }
            ]
            # if true, export installables _also_ as packages and runnables _also_ as apps
          , as-nix-cli-epiphyte ? true
          , nixpkgsConfig ? { }
          , nixpkgsOverlays ? [ ]
          , nixpkgsCrossOverlays ? [ ]
          , systems ? defaultSystems
          , debug ? false
          }:
          let
            # Validations ...
            organelles' = builtins.map validate.Organelle organelles;
            systems' = builtins.map validate.System systems;
            cells' = nixpkgs.lib.mapAttrsToList (validate.Cell cellsFrom organelles') (builtins.readDir cellsFrom);
            # Set of all std-injected outputs in the project flake
            theirself = builtins.foldl' nixpkgs.lib.attrsets.recursiveUpdate { } stdOutputs;
            # List of all flake outputs injected by std
            stdOutputs = builtins.concatLists (builtins.map stdOutputsFor systems');
            stdOutputsFor =
              system:
              builtins.map
                (
                  loadCell
                    {
                      build = system.build;
                      host = system.host;
                    }
                )
                cells';
            # Load a cell, return the flake outputs injected by std
            loadCell =
              system:
              cell:
              let
                cellArgs = {
                  inherit system;
                  inputs =
                    inputs
                      // {
                        nixpkgs =
                          import
                            nixpkgs
                            {
                              config =
                                {
                                  allowUnfree = true;
                                  allowUnsupportedSystem = true;
                                  android_sdk.accept_license = true;
                                }
                                  // nixpkgsConfig;
                              crossOverlays = nixpkgsCrossOverlays;
                              crossSystem = system.host;
                              localSystem = system.build;
                              overlays = nixpkgsOverlays;
                            };
                        nixpkgsSrc = nixpkgs;
                        self = theirself;
                      };
                };
                applySuffixes =
                  nixpkgs.lib.attrsets.mapAttrs'
                    (
                      suffix:
                      output:
                      let
                        baseSuffix = if suffix == "" then "" else "-${ suffix }";
                        systemSuffix =
                          if system.build.config == system.host.config then "" else "-${ system.host.config }";
                      in
                        {
                          name = "${ cell }${ baseSuffix }${ systemSuffix }";
                          value = output;
                        }
                    );
              in
                builtins.foldl'
                  (
                    old:
                    organelle:
                    let
                      res = loadCellOrganelle cell organelle cellArgs;
                      output =
                        if
                          res != { }
                        then
                          (
                            { "${ organelleName organelle }".${ system.build.system } = applySuffixes res; }
                              // (
                                if
                                  (organelle.clade == "installables" || organelle.clade == "runnables")
                                    && as-nix-cli-epiphyte
                                then
                                  { packages.${ system.build.system } = applySuffixes res; }
                                else
                                  { }
                              )
                              // (
                                if
                                  organelle.clade == "runnables" && as-nix-cli-epiphyte
                                then
                                  {
                                    apps.${ system.build.system } =
                                      builtins.mapAttrs (_: toFlakeApp) (applySuffixes res);
                                  }
                                else
                                  { }
                              )
                          )
                        else
                          { };
                    in
                      nixpkgs.lib.attrsets.recursiveUpdate old output
                  )
                  { }
                  organelles';
            # Each Cell's Organelle can inject a singleton or an attribute set output into the project, not both
            loadCellOrganelle =
              cell:
              organelle:
              cellArgs:
              let
                onePath = (organellePaths cellsFrom cell organelle).onePath or null;
                manyPath = (organellePaths cellsFrom cell organelle).manyPath or null;
              in
                if
                  onePath != null && builtins.pathExists onePath
                then
                  { "" = validate.OnePathImport organelle cellsFrom cell (import onePath cellArgs); }
                else
                  if
                    manyPath != null && builtins.pathExists manyPath
                  then
                    validate.ManyPathImport organelle cellsFrom cell (import manyPath cellArgs)
                  else
                    { };
            toFlakeApp =
              drv:
              let
                name = drv.meta.mainProgram or drv.pname or drv.name;
              in
                {
                  program = "${ drv }/bin/${ name }";
                  type = "app";
                };
          in
            theirself;
      systems =
        nixpkgs.lib.attrsets.mapAttrs'
          (
            example:
            config:
            let
              fullConfig = nixpkgs.lib.systems.elaborate config;
            in
              {
                name = fullConfig.config;
                value = fullConfig;
              }
          )
          (builtins.removeAttrs nixpkgs.lib.systems.examples [ "amd64-netbsd" ]);
    in
      { inherit runnables installables functions systems grow; }
        // (
          grow
            {
              inherit inputs;
              as-nix-cli-epiphyte = false;
              cellsFrom = ./cells;
              organelles = [
                (
                  runnables
                    rec {
                      o = "devShell";
                      m = o + "s";
                    }
                )
              ];
              nixpkgsOverlays = [
                devshell.overlay
                (super: self: { treefmt = treefmt.defaultPackage.${ self.system }; })
                (super: self: { alejandra = alejandra.defaultPackage.${ self.system }; })
              ];
              systems = [
                {
                  build = "x86_64-unknown-linux-gnu";
                  # GNU/Linux 64 bits
                  host = "x86_64-unknown-linux-gnu";
                  # GNU/Linux 64 bits
                }
              ];
            }
        );
}
