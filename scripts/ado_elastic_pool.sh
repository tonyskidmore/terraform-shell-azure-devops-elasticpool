#!/bin/bash

main () {
  check_env_vars
  prereqs
  printf "mode: %s\n" "$mode"
  "${mode}_func"
}

echo "PWD: $PWD"
script_dir="$(dirname "$(realpath "$0")")"
echo "script_dir: $script_dir"
functions="$script_dir/functions.sh"
echo "functions: $functions"

# shellcheck source=./scripts/functions.sh
# shellcheck disable=SC1091
source "$script_dir/functions.sh"

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
