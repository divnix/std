{
  root,
  super,
}:
/*
Use the nvfetcher Blocktype in order to generate package sources
with nvfetcher. See its docs for more details.

Available actions:
  - fetch
*/
let
  inherit (root) mkCommand actions;
  inherit (super) addSelectorFunctor;
in
  name: {
    __functor = addSelectorFunctor;
    inherit name;
    type = "nvfetcher";
    actions = {
      currentSystem,
      fragment,
      fragmentRelPath,
      target,
      inputs,
    }: let
      pkgs = inputs.nixpkgs.${currentSystem};
      inherit (pkgs) lib;
      inherit (pkgs.stdenv) isLinux;
    in [
      (mkCommand currentSystem "fetch" "update source" [pkgs.nvfetcher] ''
         targetname="$(basename ${fragmentRelPath})"
         blockpath="$(dirname ${fragmentRelPath})"
         cellpath="$(dirname "$blockpath")"
         tmpfile="$(mktemp)"
         updates="$PRJ_ROOT/${fragmentRelPath}.md"
         nvfetcher \
           --config "$PRJ_ROOT/$cellpath/nvfetcher.toml" \
           --build-dir "$PRJ_ROOT/$blockpath" \
           --changelog "$tmpfile" \
           --filter "^$targetname$"

        sed -i -e "s|^|- \`$(date --iso-8601=m)\` |" "$tmpfile"
        cat "$tmpfile" >> "$updates"
      '' {})
    ];
  }
