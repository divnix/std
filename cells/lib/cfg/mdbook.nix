{
  inputs,
  cell,
}: let
  inherit (inputs) nixpkgs;
in {
  data = {};
  output = "book.toml";
  format = "toml";
  hook.extra = d: let
    sentinel = "nixago-auto-created: mdbook-build-folder";
    file = ".gitignore";
    str = ''
      # ${sentinel}
      ${d.build.build-dir or "book"}/**
    '';
  in ''
    # Configure gitignore
    create() {
      echo -n "${str}" > "${file}"
    }
    append() {
      echo -en "\n${str}" >> "${file}"
    }
    if ! test -f "${file}"; then
      create
    elif ! grep -qF "${sentinel}" "${file}"; then
      append
    fi
  '';
  commands = [{package = nixpkgs.mdbook;}];
}
