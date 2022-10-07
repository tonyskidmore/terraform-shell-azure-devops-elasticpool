#!/bin/sh
set -eu

# functions

curlwithcode() {

  status=0
  output="output.out"
  out=""

  # Run curl in a separate command, capturing output of -w "%{http_code}" into statuscode
  # and sending the content to a file with -o >(cat >/tmp/curl_body)
  http_code=$(curl \
                --silent \
                --show-error \
                --write-out '%{http_code}' \
                --header "Content-Type: application/json" \
                --request "$1" \
                --user ":$AZURE_DEVOPS_EXT_PAT" \
                --data @params.json \
                --output "$output" \
                "$2"
  ) || status="$?"

  out=$(cat "$output")
  rm -f "$output"

}


checkout() {

  # echo "$out" > "out"
  if [ "$http_code" != "200" ]
  then
    if [ "$(echo "$out" | jq empty > /dev/null 2>&1; echo $?)" = "0" ]
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
  elif [ "$status" != "0" ]
  then
    printf "status: %s\n" "$status"
    printf "%s\n" "$out"
    exit 1
  fi

}

# end functions


printf "ADO_ORG: %s\n" "$ADO_ORG"
# GET https://dev.azure.com/fabrikam/_apis/projects?api-version=6.0
projectUrl="$ADO_ORG/_apis/projects?api-version=6.0"

curlwithcode "GET" "$projectUrl"
checkout

project=$(printf "%s" "$out" | jq -r --arg name "$ADO_PROJECT" '.value[] | select (.name==$name)')
project_id=$(echo "$project" | jq -r '.id')

printf "ADO_PROJECT: %s\n" "$ADO_PROJECT"
printf "ADO_SERVICE_CONNECTION: %s\n" "$ADO_SERVICE_CONNECTION"
# https://learn.microsoft.com/en-us/rest/api/azure/devops/serviceendpoint/endpoints/get-service-endpoints-by-names?view=azure-devops-rest-6.0&tabs=HTTP
endpointUrl="$ADO_ORG/$ADO_PROJECT/_apis/serviceendpoint/endpoints?endpointNames=$ADO_SERVICE_CONNECTION&api-version=6.0-preview.4"

curlwithcode "GET" "$endpointUrl"
checkout

endpoint_id=$(echo "$out" | jq -r '.value[].id')

# make payload for the POST request
/bin/cat <<END >params.json
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
END

printf "ADO_POOL_NAME: %s\n" "$ADO_POOL_NAME"
printf "ADO_POOL_AUTH_ALL_PIPELINES: %s\n" "$ADO_POOL_AUTH_ALL_PIPELINES"
printf "ADO_POOL_AUTO_PROVISION: %s\n" "$ADO_POOL_AUTO_PROVISION"
printf "project_id: %s\n" "$project_id"
# https://learn.microsoft.com/en-us/rest/api/azure/devops/distributedtask/elasticpools/create?view=azure-devops-rest-7.1
if [ "$ADO_PROJECT_ONLY" = "True" ]
then
  poolUrl="${ADO_ORG}/_apis/distributedtask/elasticpools?poolName=${ADO_POOL_NAME}&authorizeAllPipelines=${ADO_POOL_AUTH_ALL_PIPELINES}&autoProvisionProjectPools=${ADO_POOL_AUTO_PROVISION}&projectId=${project_id}&api-version=7.1-preview.1"
else
  poolUrl="${ADO_ORG}/_apis/distributedtask/elasticpools?poolName=${ADO_POOL_NAME}&authorizeAllPipelines=${ADO_POOL_AUTH_ALL_PIPELINES}&autoProvisionProjectPools=${ADO_POOL_AUTO_PROVISION}&api-version=7.1-preview.1"
fi
printf "poolUrl: %s\n" "$poolUrl"

curlwithcode "POST" "$poolUrl"
checkout

# cleanup
rm params.json

# https://learn.microsoft.com/en-us/rest/api/azure/devops/distributedtask/elasticpools/get?view=azure-devops-rest-7.1

poolId=$(echo "$out" | jq -r .elasticPool.poolId)
poolUrl="${ADO_ORG}/_apis/distributedtask/elasticpools/${poolId}?api-version=7.1-preview.1"

curlwithcode "GET" "$poolUrl"
checkout

printf "poolId: %s\n" "$poolId"
printf "poolUrl: %s\n" "$poolUrl"

# this will be what gets saved to state
printf "%s" "$out" | jq -r 'del(.offlineSince, .state)'
