. as $inputs |

( $checked
  | with_entries(select(.value == []))
  | keys
) as $cached

| $inputs | map( select(
 [.targetDrv] | IN($cached) | not
))
