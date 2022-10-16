#!/bin/bash

create_func () {

  # Crud - Create operation

  get_projects
  get_endpoint
  build_pool_url

  # Create the elasticpool
  rest_api_call "POST" "$poolUrl"

  # get the poolId of the new elasticpool
  pool_id=$(echo "$out" | jq -r .elasticPool.poolId)
  # switch to read mode and store details in state
  mode="read"
  get_elasticpool_by_id

}


read_func() {

  # cRud - Read operation

  # get current state
  input_state
  # update state
  get_elasticpool_by_id

}



update_func() {

  # crUd - Update operation

  # get current status
  input_state

  # build url and make call for update rest api method
  build_pool_url
  rest_api_call "PATCH" "$poolUrl"
  # update state
  get_elasticpool_by_id

}


delete_func() {

  # cruD - Delete operation

  # get current state
  input_state

  # build url and make call for delete rest api method
  build_pool_url
  rest_api_call "DELETE" "$poolUrl"

}


env_not_set() {
  printf "%s must be set before executing this script\n" "$1"
  ((failed_count++))
}


check_env_vars() {

  failed_count=0
  [[ -z "$ADO_ORG" ]] && env_not_set "ADO_ORG"
  [[ -z "$ADO_POOL_AUTH_ALL_PIPELINES" ]] && env_not_set "ADO_POOL_AUTH_ALL_PIPELINES"
  [[ -z "$ADO_POOL_AUTO_PROVISION" ]] && env_not_set "ADO_POOL_AUTO_PROVISION"
  [[ -z "$ADO_POOL_DESIRED_IDLE" ]] && env_not_set "ADO_POOL_DESIRED_IDLE"
  [[ -z "$ADO_POOL_DESIRED_SIZE" ]] && env_not_set "ADO_POOL_DESIRED_SIZE"
  [[ -z "$ADO_POOL_MAX_CAPACITY" ]] && env_not_set "ADO_POOL_MAX_CAPACITY"
  [[ -z "$ADO_POOL_MAX_SAVED_NODE_COUNT" ]] && env_not_set "ADO_POOL_MAX_SAVED_NODE_COUNT"
  [[ -z "$ADO_POOL_NAME" ]] && env_not_set "ADO_POOL_NAME"
  [[ -z "$ADO_POOL_OS_TYPE" ]] && env_not_set "ADO_POOL_OS_TYPE"
  [[ -z "$ADO_POOL_RECYCLE_AFTER_USE" ]] && env_not_set "ADO_POOL_RECYCLE_AFTER_USE"
  [[ -z "$ADO_POOL_SIZING_ATTEMPTS" ]] && env_not_set "ADO_POOL_SIZING_ATTEMPTS"
  [[ -z "$ADO_POOL_TTL_MINS" ]] && env_not_set "ADO_POOL_TTL_MINS"
  [[ -z "$ADO_PROJECT" ]] && env_not_set "ADO_PROJECT"
  [[ -z "$ADO_PROJECT_ONLY" ]] && env_not_set "ADO_PROJECT_ONLY"
  [[ -z "$ADO_SERVICE_CONNECTION" ]] && env_not_set "ADO_SERVICE_CONNECTION"
  [[ -z "$AZ_VMSS_ID" ]] && env_not_set "AZ_VMSS_ID"
  [[ -z "$AZURE_DEVOPS_EXT_PAT" ]] && env_not_set "AZURE_DEVOPS_EXT_PAT"
  [[ $failed_count -ne 0 ]] && exit 1

}


input_state() {
  # read in state from stdin
  std_in=$(cat)
  printf "std_in: %s\n" "$std_in"
  pool_id=$(echo "$std_in" | jq -r '.poolId')
  endpoint_id=$(echo "$std_in" | jq -r '.serviceEndpointId')
  project_id=$(echo "$std_in" | jq -r '.serviceEndpointScope')
}

# TODO: test this
# out='{
#   "agentInteractiveUI": false,
#   "azureId": "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-vmss-azdo-agents-01/providers/Microsoft.Compute/virtualMachineScaleSets/vmss-portal-test-001",
#   "desiredIdle": 0,
#   "maxCapacity": 2,
#   "maxSavedNodeCount": 0,
#   "osType": "linux",
#   "recycleAfterEachUse": false,
#   "serviceEndpointId": "290659e0-6f38-49da-8f20-a29070687d7c",
#   "serviceEndpointScope": "9e472165-b56d-4b28-a1ff-6d6c415d6ad3",
#   "timeToLiveMinutes": 30,
#   "offlineSince": "yesterday",
#   "state": "online"
# }'
# output_state
output_state() {
  # save state from stdout
  printf "%s" "$out" | jq -r 'del(.offlineSince, .state)'
}


get_projects() {

  # Get ADO projects to allow obtaining required project ID
  # https://learn.microsoft.com/en-us/rest/api/azure/devops/core/projects/get?view=azure-devops-rest-6.0
  projectUrl="$ADO_ORG/_apis/projects?api-version=6.0"
  rest_api_call "GET" "$projectUrl"
  project=$(printf "%s" "$out" | jq -r --arg name "$ADO_PROJECT" '.value[] | select (.name==$name)')
  project_id=$(echo "$project" | jq -r '.id')
  if [[ -n "$project_id" ]]
  then
    printf "project_id: %s\n" "$project_id"
  else
    printf "Failed to obtain project_id for project: %s\n" "$ADO_PROJECT" >&2
    exit 1
  fi

}


get_endpoint() {

  # Get endpoint ID of the specified service connection in the target project
  # https://learn.microsoft.com/en-us/rest/api/azure/devops/serviceendpoint/endpoints/get-service-endpoints-by-names?view=azure-devops-rest-6.0&tabs=HTTP
  endpointUrl="$ADO_ORG/$ADO_PROJECT/_apis/serviceendpoint/endpoints?endpointNames=$ADO_SERVICE_CONNECTION&api-version=6.0-preview.4"
  rest_api_call "GET" "$endpointUrl"
  endpoint_id=$(echo "$out" | jq -r '.value[].id')
  if [[ -n "$endpoint_id" ]]
  then
    printf "endpoint_id: %s\n" "$endpoint_id"
  else
    printf "Failed to obtain endpoint_id for service connection: %s\n" "$ADO_SERVICE_CONNECTION" >&2
    exit 1
  fi

}


build_pool_url() {

  # https://learn.microsoft.com/en-us/rest/api/azure/devops/distributedtask/elasticpools?view=azure-devops-rest-7.1
  # mode is global varaiable defined in parent script
  # shellcheck disable=SC2154
  if [[ "$mode" == "read" || "$mode" == "update" ]]
  then
    poolUrl="${ADO_ORG}/_apis/distributedtask/elasticpools/$pool_id?api-version=7.1-preview.1"
  elif [[ "$mode" == "delete" ]]
  then
    # https://learn.microsoft.com/en-us/rest/api/azure/devops/distributedtask/agents/delete?view=azure-devops-rest-7.1
    poolUrl="${ADO_ORG}/_apis/distributedtask/pools/$pool_id?api-version=7.1-preview.1"
  elif [[ "$mode" == "create" ]]
  then
    # Only specify the optional project ID if the pool is only required in the specified project, determined by if ADO_PROJECT_ONLY is True
    # https://learn.microsoft.com/en-us/rest/api/azure/devops/distributedtask/elasticpools/create?view=azure-devops-rest-7.1
    url_prefix="${ADO_ORG}/_apis/distributedtask/elasticpools?poolName=${ADO_POOL_NAME}&authorizeAllPipelines=${ADO_POOL_AUTH_ALL_PIPELINES}&autoProvisionProjectPools=${ADO_POOL_AUTO_PROVISION}"
    url_suffix="&api-version=7.1-preview.1"
    if [[ "$ADO_PROJECT_ONLY" == "True" ]]
    then
      url_suffix="&projectId=${project_id}${url_suffix}"
    fi
    poolUrl="${url_prefix}${url_suffix}"
  else
    raise "Failed to build pool URL"
    exit 1
  fi

}


get_elasticpool_by_id() {

  build_pool_url
  rest_api_call "GET" "$poolUrl"
  output_state

}


create_post_data()
{
  cat <<EOF
{
  "agentInteractiveUI": false,
  "azureId": "$AZ_VMSS_ID",
  "desiredIdle": $ADO_POOL_DESIRED_IDLE,
  "desiredSize": $ADO_POOL_DESIRED_SIZE,
  "maxCapacity": $ADO_POOL_MAX_CAPACITY,
  "maxSavedNodeCount": $ADO_POOL_MAX_SAVED_NODE_COUNT,
  "offlineSince": "",
  "osType": "$ADO_POOL_OS_TYPE",
  "recycleAfterEachUse": $ADO_POOL_RECYCLE_AFTER_USE,
  "serviceEndpointId": "$endpoint_id",
  "serviceEndpointScope": "$project_id",
  "sizingAttempts": $ADO_POOL_SIZING_ATTEMPTS,
  "state": "online",
  "timeToLiveMinutes": $ADO_POOL_TTL_MINS
}
EOF
}


update_post_data()
{
  cat <<EOF
{
  "agentInteractiveUI": false,
  "azureId": "$AZ_VMSS_ID",
  "desiredIdle": $ADO_POOL_DESIRED_IDLE,
  "maxCapacity": $ADO_POOL_MAX_CAPACITY,
  "maxSavedNodeCount": $ADO_POOL_MAX_SAVED_NODE_COUNT,
  "osType": "$ADO_POOL_OS_TYPE",
  "recycleAfterEachUse": $ADO_POOL_RECYCLE_AFTER_USE,
  "serviceEndpointId": "$endpoint_id",
  "serviceEndpointScope": "$project_id",
  "timeToLiveMinutes": $ADO_POOL_TTL_MINS
}
EOF
}


raise() {
  printf "%s\n" "$1" >&2
}


check_command () {
  # Determine if command is installed
  command -v "${1}" &>/dev/null
}


check_prereqs() {

  prereqs=("$@")

  for cmd in "${prereqs[@]}"
  do
    if ! check_command "$cmd"
    then
      # raise "Module prerequisite not installed: $cmd"
      exit 6
    fi
  done
}

# TODO: if this supplys bad command ends up in broken loop
prereqs() {
  cmds=("jq" "curl" "cat" "sed")
  check_prereqs "${cmds[@]}"
}


build_params() {

  local method="$1"
  local url="$2"

  params=(
          "--silent" \
          "--show-error" \
          "--max-time" "20" \
          "--connect-timeout" "20" \
          "--write-out" "\n%{http_code}" \
          "--header" "Content-Type: application/json" \
          "--request" "$method"
  )

  if [[ "$method" == "POST" || "$method" == "PATCH" ]]
  then
    # generate curl --data if method if POST(create) or PATCH(update)
    # mode is global varaiable defined in parent script
    # shellcheck disable=SC2154
    data_func="${mode}_post_data"
    data="$($data_func)"
    printf "data: %s\n" "$data"
    params+=("--data" "$data")
  fi

  params+=("--user" ":$AZURE_DEVOPS_EXT_PAT" "$url")

}


rest_api_call() {

  exit_code=0

  if [ "$#" -ne 2 ]
  then
      printf "Expected 2 function arguments, got %s\n" "$#"
      exit 1
  fi

  method="$1"
  local url="$2"


  if [[ "$method" == "GET" || "$method" == "POST" || "$method" == "PATCH" || "$method" == "DELETE" ]]
  then
    printf "method: %s\n" "$method"
  else
    printf "Expected method to be one of: GET,POST,PATCH.DELETE got %s\n" "$method"
    exit 1
  fi

  if [[ $url =~ ^https:\/\/.+\/_apis.+$ ]]
  then
    printf "url: %s\n" "$url"
  else
    printf "Invalid or missing URL: %s\n" "$url"
    exit 1
  fi

  build_params "$method" "$url"

  printf "curl %s\n" "${params[*]}"
  res=$(curl "${params[@]}")
  exit_code=$?

  # https://unix.stackexchange.com/questions/572424/retrieve-both-http-status-code-and-content-from-curl-in-a-shell-script
  http_code=$(tail -n1 <<< "$res") # get the last line
  out=$(sed '$ d' <<< "$res") # get all but the last line which contains the status code

  printf "http_code: %s\n" "$http_code"
  printf "out: %s\n" "$out"

  checkout

}


checkout() {

  if [[ "$exit_code" != "0" ]]
  then
    raise "Operation failed. Mode: $mode, Method: $method, exit_code: $exit_code, HTTP code: $http_code"
    printf "%s\n" "$out"
    exit 1
  else
    echo "out"
    if [[ "$mode" != "delete" && "$http_code" == "200" ]] || [[ "$mode" == "delete" && "$http_code" == "204" ]]
    then
      printf "Operation successful. Mode: %s, Method: %s, exit_code: %s, HTTP code: %s\n" "$mode" "$method" "$exit_code" "$http_code"
    else
      if [[ "$(echo "$out" | jq empty > /dev/null 2>&1; echo $?)" = "0" ]]
      then
        printf "Parsed JSON successfully and got something other than false/null\n"
        message="$(echo "$out" | jq -r '.message')"
        raise "Error: $message"
        exit 2
      else
        printf "Failed to parse JSON, or got false/null\n"
        if echo "$out" | grep -q "_signin"
        then
          raise "Azure DevOps PAT token is not correct"
          exit 4
        elif echo "$out" | grep -q "The resource cannot be found"
        then
          raise "The resource cannot be found"
          exit 5
        else
        raise "Unknown error"
          printf "%s\n" "$out"
          exit 3
        fi
      fi
    fi
  fi

}
