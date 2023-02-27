{
  inputs,
  cell,
}: let
  inherit (inputs) nixpkgs std;
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
  {
    name,
    operable,
    tag ? "",
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
    # Link useful paths into the container.
    runtimeEntryLink = "ln -s ${l.getExe operable.passthru.runtime} $out/bin/runtime";
    debugEntryLink = l.optionalString debug "ln -s ${l.getExe operable.passthru.debug} $out/bin/debug";
    livenessLink = l.optionalString (operable.passthru ? livenessProbe) "ln -s ${l.getExe operable.passthru.livenessProbe} $out/bin/live";
    readinessLink = l.optionalString (operable.passthru ? readinessProbe) "ln -s ${l.getExe operable.passthru.readinessProbe} $out/bin/ready";

    # Wrap the operable with sleep if debug is enabled
    debugOperable = cell.ops.writeScript {
      name = "debug-operable";
      runtimeInputs = [nixpkgs.coreutils];
      text = ''
        set -x
        sleep "''${DEBUG_SLEEP:-0}"
        ${l.getExe operable} "$@"
      '';
    };
    operable' =
      if debug
      then debugOperable
      else operable;

    setupLinks = cell.ops.mkSetup "links" [] ''
      mkdir -p $out/bin
      ${runtimeEntryLink}
      ${debugEntryLink}
      ${livenessLink}
      ${readinessLink}
    '';
  in
    cell.ops.mkOCI {
      inherit name tag uid gid labels options perms config meta;
      entrypoint = operable';
      setup = [setupLinks] ++ setup;
      runtimeInputs = operable.passthru.runtimeInputs;

      # Put liveness and readiness probes in a separate layer
      layers = [
        (n2c.buildLayer {
          deps =
            []
            ++ (l.optionals (operable.passthru ? livenessProbe) [(n2c.buildLayer {deps = [operable.passthru.livenessProbe];})])
            ++ (l.optionals (operable.passthru ? readinessProbe) [(n2c.buildLayer {deps = [operable.passthru.readinessProbe];})]);
          maxLayers = 10;
        })
      ];
    }
