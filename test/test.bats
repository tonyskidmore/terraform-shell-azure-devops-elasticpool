
setup() {
    load 'test_helper/bats-support/load'
    load 'test_helper/bats-assert/load'
    # get the containing directory of this file
    # use $BATS_TEST_FILENAME instead of ${BASH_SOURCE[0]} or $0,
    # as those will point to the bats executable's location or the preprocessed file respectively
    DIR="$( cd "$( dirname "$BATS_TEST_FILENAME" )" >/dev/null 2>&1 && pwd )"
    # make executables in scripts/ visible to PATH
    PATH="$DIR/../scripts:$PATH"
    # source functions.sh
    # shellcheck disable=SC1091
    source ado_elastic_pool.sh
    # cd "$BATS_TEMP_DIR"
}

# @test "can run our script" {
#     source ado_elastic_pool.sh
# }

@test "hello" {
  run hello
  echo $status
  [ "$output" == "hello" ]
  [ "$status" -eq 0 ]
}

@test "prereqs" {
  run prereqs
  # [ "$status" -eq 0 ]
  assert_success
}

# teardown() {
#     # : # rm -f /tmp/bats-tutorial-project-ran
#     :
# }
