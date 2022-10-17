#!/bin/bash

# set -eo pipefail
# set -e

main () {
  # TODO: fix this function
  check_env_vars
  prereqs
  # will hang on reading stdin if ran directly from shell
  printf "mode: %s\n" "$mode"
  "${mode}_func"
}

# shellcheck source=./scripts/functions.sh
# shellcheck disable=SC1091
source ./scripts/functions.sh

# similar method in bash to the Python:
# if __name__ == "__main__":
#     main()
# to allow the distinction of being called from the command line or via source
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]
then
  mode="$1"
  case $mode in
    create|read|update|delete)
      main ;;
    *)
      echo "Only accepts create, read, update or delete" ; exit 1;;
  esac
fi
