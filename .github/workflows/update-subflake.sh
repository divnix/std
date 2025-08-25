# create the store path of
nix store add-path --name source .

# This locks subflakes to the latest commit of std
(cd ./src/local && nix flake lock --override-input std git+file://$(pwd)/../..?rev=$(git -C ../.. rev-parse HEAD))
(cd ./src/tests && nix flake lock --override-input std git+file://$(pwd)/../..?rev=$(git -C ../.. rev-parse HEAD))
