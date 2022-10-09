#!/bin/bash

set -e

main () {
  # shellcheck source=./scripts/functions.sh
  # shellcheck disable=SC1091
  source ./scripts/functions.sh
  prereqs
  printf "mode: %s\n" "$mode"
  $mode
}

# similar method in bash to the Python:
# if __name__ == "__main__":
#     main()
# to allow the distinction of being called from the command line or via source


if [[ "${BASH_SOURCE[0]}" == "${0}" ]]
then
  mode="$1"
  case $mode in
    create|read|update|delete)
      # will hang on reading stdin if ran directlty from shell
      # so do a simple test to avoid that
      # [[ -n "$ADO_POOL_NAME" ]] && main ;;
      main ;;
    *)
      echo "Only accepts create, read, update or delete" ;;
  esac
fi
