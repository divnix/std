. as $inputs |

$inputs | map( select(
  .targetDrv | inside($uncachedDrvs)
))
