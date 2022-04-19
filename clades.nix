{
  runnables = name: {
    inherit name;
    clade = "runnables";
  };
  installables = name: {
    inherit name;
    clade = "installables";
  };
  functions = name: {
    inherit name;
    clade = "functions";
  };
  data = name: {
    inherit name;
    clade = "data";
  };
}
