setup() {
  load "test_helper/common_setup"
  _common_setup
}

# the tests for the rest_api_call function use pre-created curl output
# so are mainly targeted at confirming the checkout function behaves as expected
# and the various expected curl results

@test "prereqs" {
  run prereqs
  assert_success
}

@test "ado_elastic_pool_000" {
  run ado_elastic_pool.sh
  assert_failure
  assert_output --partial 'Only accepts create, read, update or delete'
}

@test "ado_elastic_pool_001" {
  function curl(){
    cat "$DIR/data/test_001_rest_api_call"
  }
  export ADO_ORG="https://dev.azure.com/tonyskidmore"
  run ado_elastic_pool.sh read <<< "$(<"$DIR/data/test_001_ado_elastic_pool.json")"
  assert_success
  assert_output --partial 'Operation successful. Mode: read, exit_code: 0, HTTP code: 200'
  unset curl
}
