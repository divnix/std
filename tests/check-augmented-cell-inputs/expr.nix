{inputs}:
builtins.mapAttrs (n: v:
    if v ? outPath
    then builtins.unsafeDiscardStringContext (toString v)
    else "no .outPath")
# std is too volatile as long as suflakes aren't solved
(builtins.removeAttrs inputs ["std"])
