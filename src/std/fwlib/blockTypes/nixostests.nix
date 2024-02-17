{
  root,
  super,
}:
/*
Use the NixosTests Blocktype in order to instrucement nixos
vm-based test inside your reporisory.

Available actions:
  - run
  - run-vm
  - audit-script
  - run-vm-+
*/
let
  inherit (root) mkCommand actions;
  inherit (super) addSelectorFunctor;
in
  name: {
    __functor = addSelectorFunctor;
    inherit name;
    type = "nixostests";
    actions = {
      currentSystem,
      fragment,
      fragmentRelPath,
      target,
      inputs,
    }: let
      pkgs = inputs.nixpkgs.${currentSystem};
    in [
      (mkCommand currentSystem "run" "run tests in headless vm" [] ''
        # ${target.driver}
        ${target.driver}/bin/nixos-test-driver
      '' {})
      (mkCommand currentSystem "audit-script" "audit the test script" [pkgs.bat] ''
        # ${target.driver}
        bat --language py ${target.driver}/test-script
      '' {})
      (mkCommand currentSystem "run-vm" "run tests interactively in vm" [] ''
        # ${target.driverInteractive}
        ${target.driverInteractive}/bin/nixos-test-driver
      '' {})
      (mkCommand currentSystem "run-vm+" "run tests with state from last run" [] ''
        # ${target.driverInteractive}
        ${target.driverInteractive}/bin/nixos-test-driver --keep-vm-state
      '' {})
      (mkCommand currentSystem "iptables+" "setup nat redirect 80->8080 & 443->4433" [pkgs.iptables] ''
        sudo iptables \
          --table nat \
          --insert OUTPUT \
          --proto tcp \
          --destination 127.0.0.1 \
          --dport 443 \
          --jump REDIRECT \
          --to-ports 4433
        sudo iptables \
          --table nat \
          --insert OUTPUT \
          --proto tcp \
          --destination 127.0.0.1 \
          --dport 80 \
          --jump REDIRECT \
          --to-ports 8080
      '' {})
      (mkCommand currentSystem "iptables-" "remove nat redirect 80->8080 & 443->4433" [pkgs.iptables] ''
        sudo iptables \
          --table nat \
          --delete OUTPUT -d 127.0.0.1/32 -p tcp -m tcp --dport 443 -j REDIRECT --to-ports 4433
        sudo iptables \
          --table nat \
          --delete OUTPUT -d 127.0.0.1/32 -p tcp -m tcp --dport 80 -j REDIRECT --to-ports 8080
      '' {})
    ];
  }
