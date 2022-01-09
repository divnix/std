{
  description = "The Nix Flakes framework for perfectionists with deadlines";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

  outputs = { nixpkgs, ... } @ inputs: {

    project =
      let
        defaultSystems = nixpkgs.lib.attrsets.cartesianProductOfSets {
          build = [
            "x86_64-apple-darwin"
            "x86_64-unknown-linux-gnu"
            "aarch64-unknown-linux-gnu"
          ];
          host = builtins.attrNames inputs.self.systems;
        };

        validateSystem = system:
          if builtins.hasAttr system inputs.self.systems
          then inputs.self.systems.${system}
          else
            abort ''


              System '${system}' is not valid.
              Please pick one from the following:

              ${builtins.concatStringsSep "\n"
                (builtins.attrNames inputs.self.systems)}

            '';
      in
      { extraOutputs ? { }
      , inputs
      , outputsFrom

      , nixpkgsConfig ? { }
      , nixpkgsOverlays ? [ ]
      , nixpkgsCrossOverlays ? [ ]

      , systems ? defaultSystems
      }:
      let
        # Set of all outputs in the project flake (std-injected + extraOutputs)
        theirself = builtins.foldl'
          nixpkgs.lib.attrsets.recursiveUpdate
          { }
          ([ extraOutputs ] ++ stdOutputs);

        # List of all flake outputs injected by std
        stdOutputs = builtins.concatLists (builtins.map stdOutputsFor systems);
        stdOutputsFor = system:
          builtins.map
            (loadCell {
              build = validateSystem system.build;
              host = validateSystem system.host;
            })
            (builtins.attrNames stdOutputsDir);

        # Std flake outputs are loaded from Cells, located at ${outputsFrom}/*
        stdOutputsDir = builtins.readDir outputsFrom;

        # Load a cell, return the flake outputs injected by std
        loadCell = system: cell:
          if stdOutputsDir.${cell} != "directory"
          then
            abort ''

              Everything under ''${outputsFrom}/* is considered a Cell

              Cells are directories by convention and therefore
              only directories are allowed at ''${outputsFrom}/*

              Please remove: ''${outputsFrom}/${cell}"

            ''
          else if ! (builtins.any builtins.pathExists [
            "${outputsFrom}/${cell}/app.nix"
            "${outputsFrom}/${cell}/apps.nix"
            "${outputsFrom}/${cell}/function.nix"
            "${outputsFrom}/${cell}/functions.nix"
            "${outputsFrom}/${cell}/package.nix"
            "${outputsFrom}/${cell}/packages.nix"
          ])
          then
            abort ''


              For Cell '${cell}' to be useful
              it needs to provide at least one output

              Outputs of a Cell can be of type
              'app', 'function', 'package', and 'test'

              If you wish to output one or more applications, please create:
              - ''${outputsFrom}/${cell}/app.nix or
              - ''${outputsFrom}/${cell}/apps.nix

              If you wish to output one or more functions, please create:
              - ''${outputsFrom}/${cell}/function.nix or
              - ''${outputsFrom}/${cell}/functions.nix

              If you wish to output one or more packages, please create:
              - ''${outputsFrom}/${cell}/package.nix or
              - ''${outputsFrom}/${cell}/packages.nix

              Please create at least one of the previous files
            ''
          else loadCellOnceValidated system cell;
        loadCellOnceValidated = system: cell:
          let
            cellArgs = {
              inherit system;
              inputs = inputs // {
                nixpkgs = import nixpkgs {
                  config = {
                    allowUnfree = true;
                    allowUnsupportedSystem = true;
                    android_sdk.accept_license = true;
                  } // nixpkgsConfig;
                  crossOverlays = nixpkgsCrossOverlays;
                  crossSystem = system.host;
                  localSystem = system.build;
                  overlays = nixpkgsOverlays;
                };
                nixpkgsSrc = nixpkgs;
                self = theirself;
              };
            };

            apps = loadCellOutputs cell "app" cellArgs;
            functions = loadCellOutputs cell "function" cellArgs;
            packages = loadCellOutputs cell "package" cellArgs;

            applySuffixes = nixpkgs.lib.attrsets.mapAttrs'
              (suffix: output:
                let
                  baseSuffix = if suffix == "" then "" else "-${suffix}";
                  systemSuffix =
                    if system.build.system == system.host.system
                    then "" else "-${system.host.config}";
                in
                {
                  name = "${cell}${baseSuffix}${systemSuffix}";
                  value = output;
                });
          in
          {
            apps.${system.build.system} = builtins.mapAttrs
              (_: toFlakeApp)
              (applySuffixes apps);
            functions.${system.build.system} = applySuffixes functions;
            packages.${system.build.system} = applySuffixes (apps // packages);
          };

        # Each Cell can inject one or many outputs into the project, not both
        loadCellOutputs = cell: name: cellArgs:
          let
            onePath = "${outputsFrom}/${cell}/${name}.nix";
            manyPath = "${outputsFrom}/${cell}/${name}s.nix";
          in
          if builtins.pathExists onePath && builtins.pathExists manyPath
          then
            abort ''


              Cells can inject one or many outputs into the project flake.
              For simplicity, just use one of the following files:
              - ''${outputsFrom}/${cell}/${name}.nix
              - ''${outputsFrom}/${cell}/${name}s.nix

              Please remove one or the other

            ''
          else
            if builtins.pathExists onePath
            then { "" = import onePath cellArgs; }
            else if builtins.pathExists manyPath
            then import manyPath cellArgs
            else { };

        toFlakeApp = drv:
          let name = drv.meta.mainProgram or drv.pname or drv.name;
          in { program = "${drv}/bin/${name}"; type = "app"; };
      in
      theirself;

    systems = nixpkgs.lib.attrsets.mapAttrs'
      (example: config:
        let fullConfig = nixpkgs.lib.systems.elaborate config;
        in { name = fullConfig.config; value = fullConfig; })
      (builtins.removeAttrs
        nixpkgs.lib.systems.examples
        [ "amd64-netbsd" ]);
  };
}
