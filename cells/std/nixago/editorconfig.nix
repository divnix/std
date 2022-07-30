{
  # root = true;

  "*" = {
    end_of_line = "lf";
    insert_final_newline = true;
    trim_trailing_whitespace = true;
    charset = "utf-8";
    indent_style = "space";
    indent_size = 2;
  };

  "*.{diff,patch}" = {
    end_of_line = "unset";
    insert_final_newline = "unset";
    trim_trailing_whitespace = "unset";
    indent_size = "unset";
  };

  "*.md" = {
    max_line_length = "off";
    trim_trailing_whitespace = false;
  };
}
