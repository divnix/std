_: action: func: ''
  # prompt user interactiely except in CI
  if ! [[ -v CI ]]; then
    read -rp "Proceed with ${action}? (y/N)" answer
    case "$answer" in
    [Yy])
      ${func}
      ;;
    *)
      echo "Not proceeding with ${action}."
      ;;
    esac
  else
    ${func}
  fi
''
