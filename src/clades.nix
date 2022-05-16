{nixpkgs}: let
  l = nixpkgs.lib // builtins;
in {
  /*
  Use the Runnables Clade for targets that you want to
  make accessible with a 'run' action on the TUI.
  */
  runnables = name: {
    inherit name;
    clade = "runnables";
    actions = {
      system,
      flake,
      fragment,
      fragmentRelPath,
    }: [
      {
        name = "run";
        description = "exec this target";
        command = ''
          nix run ${flake}#${fragment}
        '';
      }
    ];
  };
  /*
  Use the Installables Clade for targets that you want to
  make availabe for installation into the user's nix profile.

  Available actions:
    - install
    - upgrade
    - remove
  */
  installables = name: {
    inherit name;
    clade = "installables";
    actions = {
      system,
      flake,
      fragment,
      fragmentRelPath,
    }: [
      {
        name = "install";
        description = "install this target";
        command = ''
          nix profile install ${flake}#${fragment}
        '';
      }
      {
        name = "upgrade";
        description = "upgrade this target";
        command = ''
          nix profile upgrade ${flake}#${fragment}
        '';
      }
      {
        name = "remove";
        description = "remove this target";
        command = ''
          nix profile remove ${flake}#${fragment}
        '';
      }
    ];
  };
  /*
  Use the Functions Clade for reusable nix functions that you would
  call elswhere in the code.

  Also use this for all types of modules and profiles, since they are
  implemented as functions.

  Consequently, there are no actions available for functions.
  */
  functions = name: {
    inherit name;
    clade = "functions";
  };
  /*
  Use the Data Clade for json serializable data.

  Available actions:
    - write
    - explore

  For all actions is true:
    Nix-proper 'stringContext'-carried dependency will be realized
    to the store, if present.
  */
  data = name: {
    inherit name;
    clade = "data";
    actions = {
      system,
      flake,
      fragment,
      fragmentRelPath,
    }: let
      builder = ["nix" "build" "--impure" "--json" "--no-link" "--expr" expr];
      jq = ["|" "${nixpkgs.legacyPackages.${system}.jq}/bin/jq" "-r" "'.[].outputs.out'"];
      fx = ["|" "xargs" "cat" "|" "${nixpkgs.legacyPackages.${system}.fx}/bin/fx"];
      expr = l.strings.escapeShellArg ''
        let
          pkgs = (builtins.getFlake "${nixpkgs.sourceInfo.outPath}").legacyPackages.${system};
          this = (builtins.getFlake "${flake}").${fragment};
        in
          pkgs.writeTextFile {
            name = "data.json";
            text = builtins.toJSON this;
          }
      '';
    in [
      {
        name = "write";
        description = "write to file";
        command = l.concatStringsSep "\n" (builder ++ jq);
      }
      {
        name = "explore";
        description = "interactively explore";
        command = l.concatStringsSep "\n" (builder ++ jq ++ fx);
      }
    ];
  };
  /*
  Use the Devshells Clade for devShells.

  Available actions:
    - enter
  */
  devshells = name: {
    inherit name;
    clade = "devshells";
    actions = {
      system,
      flake,
      fragment,
      fragmentRelPath,
    }: [
      {
        name = "enter";
        description = "enter this devshell";
        command = ''
          std_layout_dir=$PRJ_ROOT/.std
          std_layout_fragment_path=$std_layout_dir/${fragmentRelPath}
          mkdir -p $std_layout_fragment_path
          nix develop \
            ${flake}#${fragment} \
            --no-update-lock-file \
            --no-write-lock-file \
            --no-warn-dirty \
            --accept-flake-config \
            --profile "$std_layout_fragment_path/profile" \
            --command "$SHELL"
        '';
      }
    ];
  };
}
