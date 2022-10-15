setup() {
  load "test_helper/common_setup"
  _common_setup
}

# these tests are for end-to-end main script functionality

@test "check script prerequisites" {
  run prereqs
  assert_success
}

@test "fail on no parameters" {
  # negative test to validate failure if no arguments supplied
  run ado_elastic_pool.sh
  assert_failure
  assert_output --partial 'Only accepts create, read, update or delete'
}

@test "read elasticpool values" {
  # positive test for GET of elasticpool by ID
  function curl(){
    cat "test/data/test_005_rest_api_call"
  }
  export -f curl
  # shellcheck disable=SC2030
  export ADO_ORG="https://dev.azure.com/tonyskidmore"
  run ado_elastic_pool.sh read <<< "$(<"$DIR/data/test_001_ado_elastic_pool_read.json")"
  assert_success
  assert_output --partial 'Operation successful. Mode: read, exit_code: 0, HTTP code: 200'

  unset curl
}

@test "delete elasticpool" {
  # positive test for GET of elasticpool by ID
  function curl(){
    printf "\n204"
  }
  export -f curl
  # shellcheck disable=SC2031
  export ADO_ORG="https://dev.azure.com/tonyskidmore"
  run ado_elastic_pool.sh delete <<< "$(<"$DIR/data/test_001_ado_elastic_pool_read.json")"
  assert_success
  assert_output --partial 'Operation successful. Mode: delete, exit_code: 0, HTTP code: 204'

  unset curl
}
