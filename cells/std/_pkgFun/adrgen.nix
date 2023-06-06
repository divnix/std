{
  inputs,
  scope,
}: {
  lib,
  buildGoModule,
  fetchFromGitHub,
  testers,
  adrgen,
}:
buildGoModule rec {
  pname = "adrgen";
  version = "2022-08-08";

  src = fetchFromGitHub {
    owner = "asiermarques";
    repo = "adrgen";
    rev = "20fe6e72f354f0fc5248522d7cdd10cb427ada29";
    sha256 = "sha256-orZPkqPPM3XlzNRDlR9+qv4ntdcmvVnRL9vkx84IZO0=";
  };

  vendorSha256 = "sha256-RXwwv3Q/kQ6FondpiUm5XZogAVK2aaVmKu4hfr+AnAM=";

  passthru.tests.version = testers.testVersion {
    package = adrgen;
    command = "adrgen version";
    version = "v${version}";
  };

  meta = with lib; {
    homepage = "https://github.com/asiermarques/adrgen";
    description = "A command-line tool for generating and managing Architecture Decision Records";
    license = licenses.mit;
    platforms = platforms.unix;
    maintainers = [maintainers.ivar];
  };
}
