{
  inputs.std.url = "github:divnix/std";
  inputs.nixpkgs.url = "nixpkgs";

  outputs = {std, ...} @ inputs:
  /*
  brings std attributes into scope
  namely used here: `growOn`, `harvest` & `clades`
  */
    with std;
    /*
    grows a flake "from cells" on "soil"; see below...
    */
      growOn {
        /*
        we always inherit inputs and expose a deSystemized version
        via {inputs, cell} during import of organelles.
        */
        inherit inputs;

        /*
        from where to "grow" cells?
        */
        cellsFrom = ./nix;

        /*
        custom organelles (i.e. "typed outputs")
        */
        organelles = [
          (clades.devshells "devshells")
          (clades.nixago "nixago")
        ];

        /*
        This debug facility helps you to explore what attributes are available
        for a given input untill you get more familiar with `std`.
        */
        debug = ["inputs" "std"];
      }
      /*

      Soil is an idiom to refer to compatibility layers that are recursively
      merged onto the outputs of the `std.grow` function.

      */
      # Soil ...
      # 1) layer for compat with the nix CLI
      {
        devShells = harvest inputs.self ["automation" "devshells"];
      }
      # 2) there can be various layers; `growOn` is a variadic function
      {};
}
