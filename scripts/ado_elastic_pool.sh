#!/bin/bash

main () {
  check_env_vars
  prereqs
  printf "mode: %s\n" "$mode"
  "${mode}_func"
}

# different source paths when runningg bats tests
if [[ -z "$BATS_TEST_FILENAME" ]]
then
  script_dir="$(dirname "$(realpath "$0")")"
  # shellcheck source=$script_dir/functions.sh
  # shellcheck disable=SC1091
  source "$script_dir/functions.sh"
else
  # shellcheck source=./scripts/functions.sh
  # shellcheck disable=SC1091
  source ./scripts/functions.sh
fi

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
