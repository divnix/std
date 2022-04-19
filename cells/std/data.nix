{
  inputs,
  cell,
}: {
  example-data = builtins.fromJSON (builtins.readFile ./data/dummy-data.json);
}
