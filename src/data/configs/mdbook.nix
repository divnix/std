{
  book = {
    language = "en";
    multilingual = false;
    src = "docs";
    title = "Documentation";
  };
  build = {
    build-dir = "docs/book";
  };
  preprocessor.paisano-preprocessor = {
    before = ["links"];
    registry = ".#__std.init";
  };
}
