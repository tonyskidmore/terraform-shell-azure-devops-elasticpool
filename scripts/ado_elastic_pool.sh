#!/bin/bash

set -e

main () {
  printf "mode: %s\n" "$mode"
  $mode
}

# shellcheck source=./scripts/functions.sh
# shellcheck disable=SC1091
source ./scripts/functions.sh
mode="$1"

# similar method in bash to the Python:
# if __name__ == "__main__":
#     main()
# to allow the distinction of being called from the command line or via source
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]
then
  prereqs
  main
fi
