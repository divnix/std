# update the subflake lockfile using git+file:// override with explicit rev
# this avoids the self-referencing issue with Nix 2.18+
(cd ./src/local && nix flake lock --override-input std git+file://$(pwd)/../..?rev=4177882c378184b795fa97594b5effd062213891 && git add -f flake.lock)
(cd ./src/tests && nix flake lock --override-input std git+file://$(pwd)/../..?rev=4177882c378184b795fa97594b5effd062213891 && git add -f flake.lock)
# continue normally ...
