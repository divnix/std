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
      else null,
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

    image =
      l.throwIf (args ? tag && meta ? tags)
      "mkOCI/mkStandardOCI/mkDevOCI: use of `tag` and `meta.tags` arguments are not supported together. Remove the former."
      n2c.buildImage (
        l.recursiveUpdate options {
          inherit name tag;

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
          copyToRoot =
            [
              (nixpkgs.buildEnv {
                name = "root";
                paths =
                  setup
                  ++ [
                    # prevent the $out`/bin` to be a symlink
                    (nixpkgs.runCommand "setupDirs" {}
                      ''
                        mkdir -p $out/bin
                      '')
                    setupLinks
                  ];
              })
            ]
            ++ options.copyToRoot or [];

          config = l.recursiveUpdate config {
            User = uid;
            Group = gid;
            Entrypoint = ["/bin/entrypoint"];
            Labels = l.mapAttrs' (n: v: l.nameValuePair "org.opencontainers.image.${n}" v) labels;
          };

          # Setup tasks can include permissions via the passthru.perms attribute
          perms = l.flatten ((l.map (s: l.optionalAttrs (s ? passthru && s.passthru ? perms) s.passthru.perms)) setup) ++ perms;
        }
      );
  in let
    mainTag =
      if tag != null && tag != ""
      then tag
      else
        builtins.unsafeDiscardStringContext
        (l.head (l.strings.splitString "-" (baseNameOf image.outPath)));
    tags = l.unique ([mainTag] ++ meta.tags or []);
  in
    cell.ops.lazyDerivation {
      inherit meta;
      derivation = image;
      passthru = {
        image.name = "${name}:${mainTag}";
        image.repo = name;
        image.tag = mainTag;
        image.tags = l.unique ([mainTag] ++ meta.tags or []);
      };
    }
