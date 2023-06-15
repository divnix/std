{
  inputs,
  cell,
}: let
  inherit (inputs) nixpkgs std;
  l = nixpkgs.lib // builtins;
  n2c = inputs.n2c.packages.nix2container;

  envToList = {...} @ args:
    if args.value != null
    then "${args.name}=${l.escapeShellArg (toString args.value)}"
    else if args.eval != null
    then "${args.name}=${args.eval}"
    else "";
in
  /*
  Creates a "development" OCI image from a devshell

  Args:
  name: The name of the image.
  devshell: The devshell derivation used to populate /nix/store
  runtimeShell: The default shell to use in the container
  user: The name to use for the container user
  vscode: If true, makes this image compatible with vscode devcontainers
  slim: If true, omits including nixpkgs and some common development tools
  tag: Optional tag of the image (defaults to output hash)
  pkgs: Additional pkgs to include in the image (symlinked to /bin)
  setup: A list of additional setup tasks to run to configure the container.
  perms: A list of permissions to set for the container.
  labels: An attribute set of labels to set for the container. The keys are
  automatically prefixed with "org.opencontainers.image".
  config: Additional options to pass to nix2container.buildImage's config.
  options: Additional options to pass to nix2container.buildImage.

  Returns:
  An OCI container image (created with nix2container).
  */
  {
    name,
    devshell,
    runtimeShell ? nixpkgs.bashInteractive,
    vscode ? false,
    slim ? false,
    user ? "user",
    tag ? null,
    pkgs ? [],
    setup ? [],
    perms ? [],
    labels ? {},
    config ? {},
    options ? {},
  }: let
    # vscode defaults to "vscode" as the user
    user' =
      if vscode
      then "vscode"
      else user;

    # Determine proper shell configuration file based on runtime shell
    # Only bash/zsh are supported currently
    shellName = builtins.unsafeDiscardStringContext (l.baseNameOf (l.getExe runtimeShell));
    shellConfigs = {
      bash = "bashrc";
      zsh = "zshrc";
    };

    # Configure local user
    setupUser = cell.ops.mkUser {
      user = user';
      group = user';
      uid = "1000";
      gid = "1000";
      shell = l.getExe runtimeShell;
      withHome = true;
      withRoot = true;
    };

    # Configure direnv, git, and nix
    setupEnv =
      cell.ops.mkSetup "container"
      [
        {
          regex = "/tmp";
          mode = "0777";
        }
      ]
      ''
        # Setup tmp folder
        mkdir -p $out/tmp

        # Enable nix flakes
        mkdir -p $out/etc
        echo "sandbox = false" > $out/etc/nix.conf
        echo "experimental-features = nix-command flakes" >> $out/etc/nix.conf

        # Increase warn timeout and whitelist all paths
        cat >$out/etc/direnv.toml << EOF
        [global]
        warn_timeout = "10m"
        [whitelist]
        prefix = [ "/" ]
        EOF

        # Add direnv shim
        cat >$out/etc/${shellConfigs.${shellName}} << EOF
        eval "\$(direnv hook ${shellName})"
        EOF

        # Put local profile in path
        echo 'export PATH="$HOME/.nix-profile/bin:/nix/var/nix/profiles/default/bin:$PATH"' >> $out/etc/${shellConfigs.${shellName}}

        # Optionally configure starship
        cat >>$out/etc/${shellConfigs.${shellName}} << EOF
        ${l.optionalString (! slim) ''eval "\$(starship init ${shellName})"''}
        EOF

        # Disable git safe directory
        cat >$out/etc/gitconfig <<EOF
          [safe]
              directory = *
        EOF
      '';

    # Setup the environment in such a way to make it compatible with what a
    # vscode devcontainer expects
    setupVSCode =
      cell.ops.mkSetup "vscode"
      [
        {
          regex = "/vscode";
          mode = "0744";
          uid = 1000;
          gid = 1000;
        }
      ]
      ''
        # Setup vscode directory
        mkdir -p $out/vscode

        # vscode uses /bin/sh for running commands
        mkdir -p $out/bin
        ln -s ${l.getExe runtimeShell} $out/bin/sh

        # The bundled nodejs binary is hardcoded to look in /lib
        ln -s ${nixpkgs.glibc}/lib $out/lib

        # Some of the bundled scripts use a /usr/bin/env shebang
        mkdir -p $out/usr/bin
        ln -s ${nixpkgs.coreutils}/bin/env $out/usr/bin/env
      '';

    # These packages are required by nix and its direnv integration
    nixDeps = [
      nixpkgs.direnv
      nixpkgs.gitMinimal
      nixpkgs.nix
      nixpkgs.gawk
      nixpkgs.gnugrep
      nixpkgs.gnused
      nixpkgs.diffutils
    ];

    # These are common packages that are useful for development
    commonDeps = [
      nixpkgs.nano
      nixpkgs.gnupg
      nixpkgs.openssh
      nixpkgs.starship
    ];

    # These packages are required by vscode
    vscodeDeps = [
      nixpkgs.gnutar
      nixpkgs.gzip
    ];

    # The entrypoint should be long-running by default
    entrypoint = cell.ops.writeScript {
      name = "entrypoint";
      text = ''
        #!${l.getExe runtimeShell}

        if [ $# -eq 0 ]; then
            while :; do sleep 2073600; done
        else
            "$@" &
        fi

        wait -n
      '';
    };
  in
    cell.ops.mkOCI {
      inherit entrypoint name tag labels perms;

      # No particular reason for using 1000 here other than it's idiomatic
      uid = "1000";
      gid = "1000";

      setup =
        [setupEnv setupUser]
        ++ setup
        ++ (l.optionals vscode [setupVSCode]);

      layers = [
        (n2c.buildLayer {
          copyToRoot = [
            (nixpkgs.buildEnv
              {
                name = "devshell";
                paths =
                  [
                    nixpkgs.coreutils
                    devshell
                    runtimeShell
                  ]
                  ++ nixDeps
                  ++ pkgs
                  ++ (l.optionals (! slim) commonDeps)
                  ++ (l.optionals vscode vscodeDeps);

                pathsToLink = ["/bin"];
              })
            # Required for fetching additional packages
            nixpkgs.cacert
          ];
          maxLayers = 100;
        })
      ];

      options = l.recursiveUpdate options {
        # Initialize the nix database so we can use the nix CLI
        initializeNixDatabase = true;

        # This configures a single-user environment where the container user
        # owns all of /nix
        nixUid = 1000;
        nixGid = 1000;

        config =
          l.recursiveUpdate (
            {
              Env =
                [
                  # Tell direnv to find it's config in /etc
                  "DIRENV_CONFIG=/etc"
                  # Required by many tools
                  "HOME=/home/${user'}"
                  # Nix related environment variables
                  "NIX_CONF_DIR=/etc"
                  "NIX_PAGER=cat"
                  # This file is created when nixpkgs.cacert is copied to the root
                  "NIX_SSL_CERT_FILE=/etc/ssl/certs/ca-bundle.crt"
                  # Nix expects a user to be set
                  "USER=${user'}"
                ]
                ++ (l.optionals vscode [
                  # vscode ships with its own nodejs binary that it uploads when the
                  # container is started. It is, unfortunately, dynamically linked and
                  # we need to resort to some hackery to get it to run.
                  "LD_LIBRARY_PATH=${nixpkgs.stdenv.cc.cc.lib}/lib"
                ])
                ++ (l.optionals (! slim) [
                  # Include <nixpkgs> to support installing additional packages
                  "NIX_PATH=nixpkgs=${nixpkgs.path}"
                ])
                ++ (map envToList devshell.passthru.config.env);
              Volumes = l.optionalAttrs vscode {"/vscode" = {};};
            }
            // (l.optionalAttrs (! vscode) {WorkingDir = "/work";})
          )
          config;
      };
    }
