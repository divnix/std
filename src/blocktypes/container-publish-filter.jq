. as $inputs

| $inputs | map( select(
  .meta.images[0] | inside($available) | not
))
