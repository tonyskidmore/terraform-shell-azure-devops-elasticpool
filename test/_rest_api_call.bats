setup() {
  load "test_helper/common_setup"
  _common_setup
}

# the tests for the rest_api_call function use pre-created curl output
# so are mainly targeted at confirming the checkout function behaves as expected

@test "prereqs" {
  run prereqs
  assert_success
}

@test "rest_api_call_001" {
  # positive test with succesful project get response
  function curl(){
    cat "$DIR/data/test_001_rest_api_call"
  }
  export -f curl
  # dummy parameters
  run rest_api_call GET https://dev.azure.com/tonyskidmore/_apis/projects?api-version=6.0
  assert_success
  unset curl
}

@test "rest_api_call_002" {
  # negative test for invalid organization name
  function curl(){
    cat "$DIR/data/test_002_rest_api_call"
  }
  export -f curl
  # dummy parameters
  run rest_api_call GET https://dev.azure.com/tonyskidmor/_apis/projects?api-version=6.0
  assert_failure 5
  assert_output --partial 'The resource cannot be found'
  assert_output --partial 'http_code: 404'
  unset curl
}

@test "rest_api_call_003" {
  # negative test with an invalid PAT token
  function curl(){
    cat "$DIR/data/test_003_rest_api_call"
  }
  export -f curl
  # dummy parameters
  run rest_api_call GET https://dev.azure.com/tonyskidmore/_apis/projects?api-version=6.0
  assert_failure 4
  assert_output --partial 'Azure DevOps PAT token is not correct'
  unset curl
}

@test "rest_api_call_004" {
  # negative test with an unexpected exit code
  function curl(){
    exit 6
  }
  export -f curl
  # dummy parameters
  run rest_api_call GET https://dev.azure.com/tonyskidmore/_apis/projects?api-version=6.0
  assert_failure 1
  assert_output --partial 'Operation failed. Mode: , exit_code: 6, HTTP code:'
  unset curl
}

@test "rest_api_call_005" {
  # positive test with succesful project get response
  function curl(){
    cat "$DIR/data/test_005_rest_api_call"
  }
  export -f curl
  # dummy parameters
  run rest_api_call GET https://dev.azure.com/tonyskidmore/_apis/distributedtask/elasticpools/275?api-version=7.1-preview.1
  assert_success
  assert_output --partial 'Operation successful. Mode: , exit_code: 0, HTTP code: 200'
  unset curl
}

@test "rest_api_call_006" {
  # negative test for a non-existent elasticpool ID
  function curl(){
    cat "$DIR/data/test_006_rest_api_call"
  }
  export -f curl
  # dummy parameters
  run rest_api_call GET https://dev.azure.com/tonyskidmore/_apis/distributedtask/elasticpools/276?api-version=7.1-preview.1
  assert_output --partial 'Error: Elastic pool not found with pool id 276'
  assert_output --partial 'http_code: 404'
  assert_failure 2
  unset curl
}

# teardown() {
#     # : # rm -f /tmp/bats-tutorial-project-ran
#     :
# }
