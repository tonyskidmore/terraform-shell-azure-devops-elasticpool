#!/bin/bash

create () {

  # Crud - Create operation

  printf "ADO_ORG: %s\n" "$ADO_ORG"

  # Get ADO projects to allow obtaining required project ID
  # https://learn.microsoft.com/en-us/rest/api/azure/devops/core/projects/get?view=azure-devops-rest-6.0
  projectUrl="$ADO_ORG/_apis/projects?api-version=6.0"
  rest_api_call "GET" "$projectUrl"
  project=$(printf "%s" "$out" | jq -r --arg name "$ADO_PROJECT" '.value[] | select (.name==$name)')
  project_id=$(echo "$project" | jq -r '.id')
  printf "project_id: %s\n" "$project_id"

  # Get endpoint ID of the specified service connection in the target project
  # https://learn.microsoft.com/en-us/rest/api/azure/devops/serviceendpoint/endpoints/get-service-endpoints-by-names?view=azure-devops-rest-6.0&tabs=HTTP
  endpointUrl="$ADO_ORG/$ADO_PROJECT/_apis/serviceendpoint/endpoints?endpointNames=$ADO_SERVICE_CONNECTION&api-version=6.0-preview.4"
  rest_api_call "GET" "$endpointUrl"
  endpoint_id=$(echo "$out" | jq -r '.value[].id')
  printf "endpoint_id: %s\n" "$endpoint_id"

  # Only specify the optional project ID if the pool is only required in the specified project, deteremioned by if ADO_PROJECT_ONLY is True
  # https://learn.microsoft.com/en-us/rest/api/azure/devops/distributedtask/elasticpools/create?view=azure-devops-rest-7.1
  url_prefix="${ADO_ORG}/_apis/distributedtask/elasticpools?poolName=${ADO_POOL_NAME}&authorizeAllPipelines=${ADO_POOL_AUTH_ALL_PIPELINES}&autoProvisionProjectPools=${ADO_POOL_AUTO_PROVISION}"
  url_suffix="&api-version=7.1-preview.1"
  if [[ "$ADO_PROJECT_ONLY" == "True" ]]
  then
    # poolUrl="${ADO_ORG}/_apis/distributedtask/elasticpools?poolName=${ADO_POOL_NAME}&authorizeAllPipelines=${ADO_POOL_AUTH_ALL_PIPELINES}&autoProvisionProjectPools=${ADO_POOL_AUTO_PROVISION}&projectId=${project_id}&api-version=7.1-preview.1"
    url_suffix="&projectId=${project_id}${url_suffix}"
  # else
  #   poolUrl="${ADO_ORG}/_apis/distributedtask/elasticpools?poolName=${ADO_POOL_NAME}&authorizeAllPipelines=${ADO_POOL_AUTH_ALL_PIPELINES}&autoProvisionProjectPools=${ADO_POOL_AUTO_PROVISION}&api-version=7.1-preview.1"
  fi
  poolUrl="${url_prefix}${url_suffix}"

  # Create the elasticpool
  printf "poolUrl: %s\n" "$poolUrl"
  rest_api_call "POST" "$poolUrl"

  # query the new pool using the poolId returned by the create REST API call
  # https://learn.microsoft.com/en-us/rest/api/azure/devops/distributedtask/elasticpools/get?view=azure-devops-rest-7.1
  poolId=$(echo "$out" | jq -r .elasticPool.poolId)
  poolUrl="${ADO_ORG}/_apis/distributedtask/elasticpools/${poolId}?api-version=7.1-preview.1"
  printf "poolId: %s\n" "$poolId"
  printf "poolUrl: %s\n" "$poolUrl"
  rest_api_call "GET" "$poolUrl"

  # this will be what gets saved to state
  output_state

}


read() {

  # cRud - Read operation
  input_state

  poolId=$(echo "$std_in" | jq -r '.poolId')
  printf "poolId: %s\n" "$poolId"

  # https://learn.microsoft.com/en-us/rest/api/azure/devops/distributedtask/elasticpools/get?view=azure-devops-rest-7.1
  poolUrl="$ADO_ORG/_apis/distributedtask/elasticpools/${poolId}?api-version=7.1-preview.1"

  rest_api_call "GET" "$poolUrl"

  output_state

}


update() {

  # crUd - Update operation
  input_state
  pool_id=$(echo "$std_in" | jq -r '.poolId')
  endpoint_id=$(echo "$std_in" | jq -r '.serviceEndpointId')
  project_id=$(echo "$std_in" | jq -r '.serviceEndpointScope')

  # https://learn.microsoft.com/en-us/rest/api/azure/devops/distributedtask/elasticpools/update?view=azure-devops-rest-7.1
  poolUrl="${ADO_ORG}/_apis/distributedtask/elasticpools/$pool_id?api-version=7.1-preview.1"

  rest_api_call "PATCH" "$poolUrl"

  # do GET - this will be what gets saved to state
  poolUrl="${ADO_ORG}/_apis/distributedtask/elasticpools/$pool_id?api-version=7.1-preview.1"

  rest_api_call "GET" "$poolUrl"
  output_state

}


delete() {

  # cruD - Delete operation
  input_state
  pool_id=$(echo "$std_in" | jq -r '.poolId')

  # https://learn.microsoft.com/en-us/rest/api/azure/devops/distributedtask/agents/delete?view=azure-devops-rest-7.1
  poolUrl="$ADO_ORG/_apis/distributedtask/pools/$pool_id?api-version=7.1-preview.1"

  rest_api_call "DELETE" "$poolUrl"

}


input_state() {
  # read in state from stdin
  std_in=$(cat)
  printf "std_in: %s\n" "$std_in"
}


output_state() {
  # save state from stdout
  printf "%s" "$out" | jq -r 'del(.offlineSince, .state)'
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
  "osType": "linux",
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
  "osType": "linux",
  "recycleAfterEachUse": $ADO_POOL_RECYCLE_AFTER_USE,
  "serviceEndpointId": "$endpoint_id",
  "serviceEndpointScope": "$project_id",
  "timeToLiveMinutes": $ADO_POOL_TTL_MINS
}
EOF
}


rest_api_call() {

  status=0
  local method="$1"
  local url="$2"

  printf "method: %s\n" "$method"

  params=(
          "--silent" \
          "--show-error" \
          "--write-out" "\n%{http_code}" \
          "--header" "Content-Type: application/json" \
          "--request" "$1"
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

  # uncomment for debug
  # declare -p params

  # Run curl in a separate command, capturing output of -w "%{http_code}" into statuscode
  # and sending the content to a file with -o >(cat >/tmp/curl_body)
  printf "curl %s\n" "${params[*]}"
  res=$(curl "${params[@]}") || status=$?

  # https://unix.stackexchange.com/questions/572424/retrieve-both-http-status-code-and-content-from-curl-in-a-shell-script
  http_code=$(tail -n1 <<< "$res") # get the last line
  out=$(sed '$ d' <<< "$res") # get all but the last line which contains the status code

  printf "http_code: %s\n" "$http_code"
  printf "out: %s\n" "$out"

  checkout

}


checkout() {

  if [[ "$mode" != "delete" && "$http_code" != "200" ]]
  then
    if [[ "$(echo "$out" | jq empty > /dev/null 2>&1; echo $?)" = "0" ]]
    then
      echo "Parsed JSON successfully and got something other than false/null"
      message="$(echo "$out" | jq -r '.message')"
      printf "Error: %s\n" "$message" >&2
      exit 1
    else
      printf "Failed to parse JSON, or got false/null.\n" >&2
      if echo "$out" | grep -q "_signin"
      then
        printf "Azure DevOps PAT token is not correct\n" >&2
        exit 1
      elif echo "$out" | grep -q "The resource cannot be found."
      then
        printf "The resource cannot be found.\n" >&2
        exit 1
      else
        printf "%s\n" "$out"
        exit 1
      fi
    fi
  elif [[ "$mode" == "delete" && "$http_code" != "204" ]]
  then
    printf "Destroy operation did not return expected 204, returned: %s.\n" "$http_code" >&2
    exit 1
  elif [[ "$status" != "0" ]]
  then
    printf "status: %s\n" "$status"  >&2
    printf "%s\n" "$out"
    exit 1
  fi

  printf "Operation successful. Mode: %s, Status: %s, HTTP code: %s\n" "$mode" "$status" "$http_code"

}
