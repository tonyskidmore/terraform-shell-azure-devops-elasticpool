setup() {
  load "test_helper/common_setup"
  _common_setup
}

teardown() {
    rm -rf "/tmp/$BATS_TEST_TMPDIR"
}

# these tests are for end-to-end main script functionality

@test "successScriptPrerequisites" {
  run prereqs
  assert_success
}

@test "failureNoParameters" {
  # negative test to validate failure if no arguments supplied
  run ado_elastic_pool.sh
  assert_failure
  assert_output --partial 'Only accepts create, read, update or delete'
}

@test "successReadElasticpool" {
  # positive test for GET of elasticpool by ID
  function curl(){
    cat "test/data/test_001_ado_elastic_pool_read"
  }
  export -f curl
  # shellcheck disable=SC1091
  source "$DIR/test_helper/env_vars_rc"
  # shellcheck disable=SC2030
  run ado_elastic_pool.sh read <<< "$(<"$DIR/data/test_001_ado_elastic_pool_read.json")"
  assert_success
  assert_output --partial 'Operation successful. Service: distributedtask, Mode: read, Method: GET, exit_code: 0, HTTP code: 200'
  unset curl
}

@test "successDeleteElasticpool" {
  # positive test for GET of elasticpool by ID
  function curl(){
    printf "\n204"
  }
  export -f curl
  # shellcheck disable=SC1091
  source "$DIR/test_helper/env_vars_rc"
  run ado_elastic_pool.sh delete <<< "$(<"$DIR/data/test_001_ado_elastic_pool_read.json")"
  assert_success
  assert_output --partial 'Operation successful. Service: distributedtask, Mode: delete, Method: DELETE, exit_code: 0, HTTP code: 204'

  unset curl
}

@test "successUpdateElasticpool" {
  # positive test for PATCH of elasticpool by ID
  function curl(){
    if echo "$@" | grep -q "PATCH"
    then
      cat "test/data/test_002_ado_elastic_pool_update"
    elif echo "$@" | grep -q "GET"
    then
      cat "test/data/test_002_ado_elastic_pool_update"
    else
      exit 1
    fi
  }
  export -f curl
  # shellcheck disable=SC1091
  source "$DIR/test_helper/env_vars_rc"
  # shellcheck disable=SC2031
  export ADO_POOL_TTL_MINS=45
  run ado_elastic_pool.sh update <<< "$(<"$DIR/data/test_001_ado_elastic_pool_read.json")"
  assert_success
  assert_output --partial 'Operation successful. Service: distributedtask, Mode: update, Method: PATCH, exit_code: 0, HTTP code: 200'
  assert_output --partial 'Operation successful. Service: distributedtask, Mode: update, Method: GET, exit_code: 0, HTTP code: 200'
  unset curl
}

@test "successCreateElasticpool" {
  # positive test for PATCH of elasticpool by ID
  function curl(){
    if echo "$@" | grep -q "POST"
    then
      cat "test/data/test_003_ado_elastic_pool_create_pool"
    elif echo "$@" | grep -q "GET" && echo "$@" | grep -q "projects"
    then
      cat "test/data/test_003_ado_elastic_pool_create_project"
    elif echo "$@" | grep -q "GET" && echo "$@" | grep -q "serviceendpoint"
    then
      cat "test/data/test_003_ado_elastic_pool_create_endpoint"
    elif echo "$@" | grep -q "GET" && echo "$@" | grep -q "distributedtask"
    then
      cat "test/data/test_003_ado_elastic_pool_create_get_pool"
    else
      exit 1
    fi
  }
  export -f curl
  # shellcheck disable=SC1091
  source "$DIR/test_helper/env_vars_rc"
  run ado_elastic_pool.sh create
  assert_success
  assert_output --partial 'Operation successful. Service: projects, Mode: create, Method: GET, exit_code: 0, HTTP code: 200'
  assert_output --partial 'Operation successful. Service: serviceendpoint, Mode: create, Method: GET, exit_code: 0, HTTP code: 200'
  assert_output --partial 'Operation successful. Service: distributedtask, Mode: create, Method: POST, exit_code: 0, HTTP code: 200'
  assert_output --partial 'Operation successful. Service: distributedtask, Mode: read, Method: GET, exit_code: 0, HTTP code: 200'
  unset curl
}

@test "failureCreateElasticpool" {
  # negative test for invalid URL
  function curl(){
    echo "curl: (6) Could not resolve host: invalidurl.com" >&2
    exit 6
  }
  export -f curl
  # shellcheck disable=SC1091
  source "$DIR/test_helper/env_vars_rc"
  run ado_elastic_pool.sh create
  assert_failure
  assert_output --partial "curl: (6) Could not resolve host: invalidurl.com"
  assert_output --partial "Operation failed. Mode: create, Method: GET, exit_code: 6, HTTP code:"
  unset curl
}

@test "failureUpdateNoEnvVars" {
  # negative test for environment variables not set
  export AZURE_DEVOPS_EXT_PAT="dummypat"
  run ado_elastic_pool.sh update
  assert_failure 1
  assert_output --partial "ADO_ORG must be set before executing this script"
  assert_output --partial "ADO_PROJECT must be set before executing this script"
}

@test "failureCreateElasticpoolUnauth" {
  # negative test for unauthorized PAT, probably valid PAT but with incorrect permissions
  function curl(){
    if echo "$@" | grep -q "POST"
    then
      cat "test/data/test_003_ado_elastic_pool_create_pool"
    elif echo "$@" | grep -q "GET" && echo "$@" | grep -q "projects"
    then
      cat "test/data/test_003_ado_elastic_pool_create_project"
    elif echo "$@" | grep -q "GET" && echo "$@" | grep -q "serviceendpoint"
    then
      cat "test/data/test_003_ado_elastic_pool_create_project_unauth"
    elif echo "$@" | grep -q "GET" && echo "$@" | grep -q "distributedtask"
    then
      cat "test/data/test_003_ado_elastic_pool_create_get_pool"
    else
      exit 1
    fi
  }
  export -f curl
  # shellcheck disable=SC1091
  source "$DIR/test_helper/env_vars_rc"
  run ado_elastic_pool.sh create
  assert_failure
  assert_output --partial '401 Unauthorized, probable PAT permissions issue'
  unset curl
}
