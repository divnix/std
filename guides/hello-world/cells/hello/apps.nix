{
  inputs,
  cell,
}: {
  default = inputs.nixpkgs.stdenv.mkDerivation rec {
    pname = "hello";
    version = "2.10";
    src = inputs.nixpkgs.fetchurl {
      url = "mirror://gnu/hello/${pname}-${version}.tar.gz";
      sha256 = "0ssi1wpaf7plaswqqjwigppsg5fyh99vdlb9kzl7c9lng89ndq1i";
    };
  };
}
