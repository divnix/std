{
  inputs,
  cell,
}: let
  inherit (inputs) nixpkgs std;
  l = nixpkgs.lib // builtins;
  n2c = inputs.n2c.packages.nix2container;
in
  {
    name,
    devshell,
    runtimeShell ? nixpkgs.bashInteractive,
    user ? "vscode",
    tag ? "",
    setup ? [],
    perms ? [],
    labels ? {},
    options ? {},
  }: let
    # Apply the correct hook based on the given runtime shell
    # Only bash/zsh are supported currently
    shellName = builtins.unsafeDiscardStringContext (l.baseNameOf (l.getExe runtimeShell));
    shellConfigs = {
      bash = "bashrc";
      zsh = "zshrc";
    };

    # Configure local user
    setupUser = cell.ops.mkUser {
      inherit user;
      group = user;
      uid = "1000";
      gid = "1000";
      withHome = true;
      withRoot = true;
    };

    # Configure direnv, git, and nix. Additionally, perform some setup for
    # vscode which makes some basic assumptions about the environment.
    setupEnv =
      cell.ops.mkSetup "container"
      [
        {
          regex = "/vscode";
          mode = "0744";
          uid = 1000;
          gid = 1000;
        }
        {
          regex = "/tmp";
          mode = "0777";
        }
      ]
      ''
        # Setup tmp folder
        mkdir -p $out/tmp

        # Setup vscode directory
        mkdir -p $out/vscode

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

        # Disable git safe directory
        cat >$out/etc/gitconfig <<EOF
          [safe]
              directory = *
        EOF

        # vscode uses /bin/sh for running commands
        mkdir -p $out/bin
        ln -s ${l.getExe runtimeShell} $out/bin/sh

        # The bundled nodejs binary is hardcoded to look in /lib
        ln -s ${nixpkgs.glibc}/lib $out/lib

        # Some of the bundled scripts use a /usr/bin/env shebang
        mkdir -p $out/usr/bin
        ln -s ${nixpkgs.coreutils}/bin/env $out/usr/bin/env
      '';

    # These packages are required by nix and its direnv integration test
    nixDeps = [
      nixpkgs.direnv
      nixpkgs.git
      nixpkgs.nix
      nixpkgs.gawk
      nixpkgs.gnugrep
      nixpkgs.gnused
      nixpkgs.diffutils
    ];

    # These packages are required by vscode
    vscodeDeps = [
      nixpkgs.gnutar
      nixpkgs.gzip
    ];

    # These are common packages that are useful for development
    commonDeps = [
      nixpkgs.nano
      nixpkgs.gnupg
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
        [
          setupEnv
          setupUser
        ]
        ++ setup;

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
                  ++ commonDeps
                  ++ nixDeps
                  ++ vscodeDeps;

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

        config = {
          Env = [
            # Tell direnv to find it's config in /etc
            "DIRENV_CONFIG=/etc"
            # Required by many tools
            "HOME=/home/${user}"
            # Nix related environment variables
            "NIX_CONF_DIR=/etc"
            "NIX_PAGER=cat"
            # This file is created when nixpkgs.cacert is copied to the root
            "NIX_SSL_CERT_FILE=/etc/ssl/certs/ca-bundle.crt"
            # Pin <nixpkgs> to the version used to build the container
            "NIX_PATH=nixpkgs=${nixpkgs.path}"
            # Nix expects a user to be set
            "USER=${user}"
            # vscode ships with its own nodejs binary that it uploads when the
            # container is started. It is, unfortunately, dynamically linked and
            # we need to resort to some hackery to get it to run.
            "LD_LIBRARY_PATH=${nixpkgs.stdenv.cc.cc.lib}/lib"
          ];
          Volumes = {
            "/vscode" = {};
          };
        };
      };
    }
