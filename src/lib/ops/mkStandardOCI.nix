{
  inputs,
  cell,
}: let
  inherit (inputs) nixpkgs dmerge;
  l = nixpkgs.lib // builtins;
  n2c = inputs.n2c.packages.nix2container;
in
  /*
  Creates an OCI container image using the given operable.

  Args:
  name: The name of the image.
  operable: The operable to wrap in the image.
  tag: Optional tag of the image (defaults to output hash)
  setup: A list of setup tasks to run to configure the container.
  uid: The user ID to run the container as.
  gid: The group ID to run the container as.
  perms: A list of permissions to set for the container.
  labels: An attribute set of labels to set for the container. The keys are
  automatically prefixed with "org.opencontainers.image".
  debug: Whether to include debug tools in the container (coreutils).
  config: Additional options to pass to nix2container.buildImage's config.
  options: Additional options to pass to nix2container.

  Returns:
  An OCI container image (created with nix2container).
  */
  args @ {
    name,
    operable,
    tag ? null,
    setup ? [],
    uid ? "65534",
    gid ? "65534",
    perms ? [],
    labels ? {},
    debug ? false,
    config ? {},
    options ? {},
    meta ? {},
  }: let
    inherit (operable) livenessProbe readinessProbe runtimeInputs runtime debug;

    hasLivenessProbe = operable ? livenessProbe;
    hasReadinessProbe = operable ? readinessProbe;
    hasDebug = args.debug or false;

    # Link useful paths into the container.
    runtimeShell = l.getExe runtime;
    runtimeEntryLink = ''
      ln -s ${runtimeShell} $out/bin/sh
      ln -s ${runtimeShell} $out/bin/runtime
    '';
    debugEntryLink = l.optionalString hasDebug "ln -s ${l.getExe debug} $out/bin/debug";
    livenessLink = l.optionalString hasLivenessProbe "ln -s ${l.getExe livenessProbe} $out/bin/live";
    readinessLink = l.optionalString hasReadinessProbe "ln -s ${l.getExe readinessProbe} $out/bin/ready";

    # Wrap the operable with sleep if debug is enabled
    debugOperable = cell.ops.writeScript {
      name = "debug-operable";
      runtimeInputs = [nixpkgs.coreutils];
      text = ''
        if [[ -v DEBUG_SLEEP ]]; then
          >&2 "Sleeping for $DEBUG_SLEEP for debugging"
          sleep "$DEBUG_SLEEP"
        fi
        exec ${l.getExe operable} "$@"
      '';
    };
    operable' =
      if hasDebug
      then debugOperable
      else operable;

    inherit (nixpkgs.dockerTools) caCertificates;
    setupLinks =
      cell.ops.mkSetup "links" [
        {
          regex = "/bin";
          mode = "0555";
        }
      ] ''
        mkdir -p $out/bin
        ${runtimeEntryLink}
        ${debugEntryLink}
        ${livenessLink}
        ${readinessLink}
      '';

    users = cell.ops.mkUser {
      user = "nobody";
      group = "nogroup";
      uid = "65534";
      gid = "65534";
      withRoot = true;
      withHome = true;
    };

    tmp = nixpkgs.runCommand "tmp" {} ''
      mkdir -p $out/tmp
    '';

    nss = nixpkgs.writeTextDir "etc/nsswitch.conf" ''
      hosts: files dns
    '';
  in
    with dmerge;
      cell.ops.mkOCI (
        merge
        ({
            inherit name uid gid labels options perms config meta setup runtimeInputs;
            entrypoint = operable';
          }
          # keep this optional so that mkOCI can likewise
          # match undefined on args ? tag
          // l.optionalAttrs (args ? tag) {inherit tag;})
        {
          # mkStandardOCI differentiators over mkOCI
          # - live & readiness probes
          # - user & nss setup
          # - world writable /tmp & curl's certificates bundle
          # - env setup w.r.t. certs for ssl-library ecosysystems
          layers = [
            # Put liveness and readiness probes in a separate layer
            (n2c.buildLayer {
              maxLayers = 10;
              deps =
                (l.optionals hasLivenessProbe [(n2c.buildLayer {deps = [livenessProbe];})])
                ++ (l.optionals hasReadinessProbe [(n2c.buildLayer {deps = [readinessProbe];})]);
            })
          ];
          setup = prepend [setupLinks users nss];
          options.copyToRoot = append [tmp caCertificates];
          perms = prepend [
            {
              path = tmp;
              regex = ".*";
              mode = "0777";
            }
          ];
          config.Env = append [
            # compatibility
            #  - openssl
            "SSL_CERT_FILE=/etc/ssl/certs/ca-bundle.crt"
            #  - Haskell x509-system
            "SYSTEM_CERTIFICATE_PATH=/etc/ssl/certs/ca-bundle.crt"
          ];
        }
      )
