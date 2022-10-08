#!/bin/bash

set -eu

main () {
  printf "mode: %s\n" "$mode"
  $mode
}

# shellcheck source=./scripts/functions.sh
source ./scripts/functions.sh
mode="$1"
main
