{
  inputs,
  cell,
}: let
  inherit (inputs) nixpkgs std;
  l = nixpkgs.lib // builtins;
  n2c = inputs.n2c.packages.nix2container;
in
  /*
  Creates an OCI container image

  Args:
  name: The name of the image.
  entrypoint: The entrypoint of the image. Must be a derivation.
  tag: Optional tag of the image (defaults to output hash)
  setup: A list of setup tasks to run to configure the container.
  uid: The user ID to run the container as.
  gid: The group ID to run the container as.
  perms: A list of permissions to set for the container.
  labels: An attribute set of labels to set for the container. The keys are
  automatically prefixed with "org.opencontainers.image".
  config: Additional options to pass to nix2container.buildImage's config.
  options: Additional options to pass to nix2container.buildImage.

  Returns:
  An OCI container image (created with nix2container).
  */
  args @ {
    name,
    entrypoint,
    tag ?
      if meta ? tags && (l.length meta.tags) > 0
      then l.head meta.tags
      else "",
    setup ? [],
    layers ? [],
    runtimeInputs ? [],
    uid ? "65534",
    gid ? "65534",
    perms ? [],
    labels ? {},
    config ? {},
    options ? {},
    meta ? {},
  }: let
    setupLinks = cell.ops.mkSetup "links" [] ''
      mkdir -p $out/bin
      ln -s ${l.getExe entrypoint} $out/bin/entrypoint
    '';
    options' =
      {
        inherit name meta;

        # Layers are nested to reduce duplicate paths in the image
        layers =
          [
            # Primary layer is the entrypoint layer
            (n2c.buildLayer {
              deps = [entrypoint];
              maxLayers = 50;
              layers = [
                # Runtime inputs layer
                (n2c.buildLayer {
                  deps = runtimeInputs;
                  maxLayers = 10;
                })
              ];
            })
          ]
          ++ layers;

        maxLayers = 25;
        copyToRoot = [setupLinks] ++ setup;

        config =
          l.recursiveUpdate {
            User = uid;
            Group = gid;
            Entrypoint = ["/bin/entrypoint"];
            Labels = l.mapAttrs' (n: v: l.nameValuePair "org.opencontainers.image.${n}" v) labels;
          }
          config;

        # Setup tasks can include permissions via the passthru.perms attribute
        perms = l.flatten ((l.map (s: l.optionalAttrs (s ? passthru && s.passthru ? perms) s.passthru.perms)) setup) ++ perms;
      }
      // l.throwIf (args ? tag && meta ? tags)
      "mkOCI: use of `tag` and `meta.tags` arguments are not supported together. Remove the former."
      (l.optionalAttrs (tag != "") {inherit tag;});
  in
    n2c.buildImage (l.recursiveUpdate options' options)
