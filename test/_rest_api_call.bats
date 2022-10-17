setup() {
  load "test_helper/common_setup"
  _common_setup
}

# the tests for the rest_api_call function use pre-created curl output
# so are mainly targeted at confirming the checkout function behaves as expected
# and the various expected curl results

@test "rest_api_call_000" {
  # negative test for calling function with incorrect number of parameters
  run rest_api_call
  assert_failure
  assert_output --partial 'Expected 2 function arguments, got 0'
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
  assert_output --partial 'Operation failed. Mode: , Method: GET, exit_code: 6, HTTP code:'
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
  assert_output --partial 'Operation successful. Service: distributedtask, Mode: , Method: GET, exit_code: 0, HTTP code: 200'
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

@test "rest_api_call_007" {
  # negative test for a non-existent elasticpool ID
  # dummy url parameter
  run rest_api_call PUT https://dev.azure.com/tonyskidmore/_apis/distributedtask/elasticpools/276?api-version=7.1-preview.1
  assert_failure
  assert_output --partial 'Expected method to be one of: GET,POST,PATCH.DELETE got PUT'
}

@test "rest_api_call_008" {
  # negative test for invalid URL
  run rest_api_call GET http://dev.azure.com/tonyskidmore/_apis/projects?api-version=6.0
  assert_failure
  assert_output --partial 'Invalid or missing URL: http://dev.azure.com/tonyskidmore/_apis/projects?api-version=6.0'
}

# teardown() {
#     # : # rm -f /tmp/bats-tutorial-project-ran
#     :
# }
