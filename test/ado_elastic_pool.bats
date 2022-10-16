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
    cat "test/data/test_001_ado_elastic_pool_read"
  }
  export -f curl
  # shellcheck disable=SC2030
  export ADO_ORG="https://dev.azure.com/tonyskidmore"
  run ado_elastic_pool.sh read <<< "$(<"$DIR/data/test_001_ado_elastic_pool_read.json")"
  assert_success
  assert_output --partial 'Operation successful. Mode: read, Method: GET, exit_code: 0, HTTP code: 200'

  unset curl
}

@test "delete elasticpool" {
  # positive test for GET of elasticpool by ID
  function curl(){
    printf "\n204"
  }
  export -f curl
  # shellcheck disable=SC2030,SC2031
  export ADO_ORG="https://dev.azure.com/tonyskidmore"
  run ado_elastic_pool.sh delete <<< "$(<"$DIR/data/test_001_ado_elastic_pool_read.json")"
  assert_success
  assert_output --partial 'Operation successful. Mode: delete, Method: DELETE, exit_code: 0, HTTP code: 204'

  unset curl
}

@test "update elasticpool" {
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
  # shellcheck disable=SC2031
  export ADO_ORG="https://dev.azure.com/tonyskidmore"
  export AZURE_DEVOPS_EXT_PAT="dummypat"
  export AZ_VMSS_ID="/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-vmss-azdo-agents-01/providers/Microsoft.Compute/virtualMachineScaleSets/vmss-portal-test-001"
  export ADO_POOL_DESIRED_IDLE=0
  export ADO_POOL_MAX_CAPACITY=2
  export ADO_POOL_MAX_SAVED_NODE_COUNT=0
  export ADO_POOL_OS_TYPE="linux"
  export ADO_POOL_RECYCLE_AFTER_USE="false"
  export ADO_POOL_TTL_MINS=45
  run ado_elastic_pool.sh update <<< "$(<"$DIR/data/test_001_ado_elastic_pool_read.json")"
  assert_success
  assert_output --partial Operation successful. Mode: update, Method: PATCH, exit_code: 0, HTTP code: 200
  assert_output --partial Operation successful. Mode: update, Method: GET, exit_code: 0, HTTP code: 200
  unset curl
}
