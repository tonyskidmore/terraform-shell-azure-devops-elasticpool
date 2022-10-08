#!/bin/bash

set -eu

# mode="$1"
# printf "mode: %s\n" "$mode"

# # shellcheck source=./scripts/functions.sh
# source ./scripts/functions.sh

# test=$(hello)
# printf "test: %s\n" "$test"

# [[ "$test" == "Hello world" ]] && echo "test pass"

# functions

# curlwithcode() {

#   status=0
#   output="output.out"
#   out=""

#   # Run curl in a separate command, capturing output of -w "%{http_code}" into statuscode
#   # and sending the content to a file with -o >(cat >/tmp/curl_body)
#   http_code=$(curl \
#                 --silent \
#                 --show-error \
#                 --write-out '%{http_code}' \
#                 --header "Content-Type: application/json" \
#                 --request "$1" \
#                 --user ":$AZURE_DEVOPS_EXT_PAT" \
#                 --data @params.json \
#                 --output "$output" \
#                 "$2"
#   ) || status="$?"

#   out=$(cat "$output")
#   rm -f "$output"

# }

# checkout() {

#   if [ "$http_code" != "200" ]
#   then
#     if [ "$(echo "$out" | jq empty > /dev/null 2>&1; echo $?)" = "0" ]
#     then
#       echo "Parsed JSON successfully and got something other than false/null"
#       message="$(echo "$out" | jq -r '.message')"
#       printf "Error: %s\n" "$message" >&2
#       exit 1
#     else
#       printf "Failed to parse JSON, or got false/null.\n" >&2
#       if echo "$out" | grep -q "_signin"
#       then
#         printf "Azure DevOps PAT token is not correct\n" >&2
#         exit 1
#       elif echo "$out" | grep -q "The resource cannot be found."
#       then
#         printf "The resource cannot be found.\n" >&2
#         exit 1
#       else
#         printf "%s\n" "$out"
#         exit 1
#       fi
#     fi
#   elif [ "$status" != "0" ]
#   then
#     printf "status: %s\n" "$status"  >&2
#     printf "%s\n" "$out"
#     exit 1
#   fi

# }

# end functions

# if [ "$mode" = "read" ]
# then
#   std_in=$(cat)
#   printf "std_in: %s\n" "$std_in"
#   poolId=$(echo "$std_in" | jq -r '.poolId')
#   printf "poolId: %s\n" "$poolId"

#   # https://learn.microsoft.com/en-us/rest/api/azure/devops/distributedtask/elasticpools/get?view=azure-devops-rest-7.1
#   poolUrl="$ADO_ORG/_apis/distributedtask/elasticpools/${poolId}?api-version=7.1-preview.1"

#   curlwithcode "GET" "$poolUrl"
#   checkout

#   printf "%s" "$out" | jq -r 'del(.offlineSince, .state)'
# fi

main () {

  # mode="$1"
  printf "mode: %s\n" "$mode"

  # shellcheck source=./scripts/functions.sh
  # source ./scripts/functions.sh

  # test=$(hello)
  # printf "test: %s\n" "$test"

  # [[ "$test" == "Hello world" ]] && echo "test pass"
  $mode
}

# if [ "$mode" = "create" ]
# then
#   printf "ADO_ORG: %s\n" "$ADO_ORG"
#   # GET https://dev.azure.com/fabrikam/_apis/projects?api-version=6.0
#   projectUrl="$ADO_ORG/_apis/projects?api-version=6.0"

#   curlwithcode "GET" "$projectUrl"
#   checkout

#   project=$(printf "%s" "$out" | jq -r --arg name "$ADO_PROJECT" '.value[] | select (.name==$name)')
#   project_id=$(echo "$project" | jq -r '.id')

#   printf "ADO_PROJECT: %s\n" "$ADO_PROJECT"
#   printf "ADO_SERVICE_CONNECTION: %s\n" "$ADO_SERVICE_CONNECTION"
#   # https://learn.microsoft.com/en-us/rest/api/azure/devops/serviceendpoint/endpoints/get-service-endpoints-by-names?view=azure-devops-rest-6.0&tabs=HTTP
#   endpointUrl="$ADO_ORG/$ADO_PROJECT/_apis/serviceendpoint/endpoints?endpointNames=$ADO_SERVICE_CONNECTION&api-version=6.0-preview.4"

#   curlwithcode "GET" "$endpointUrl"
#   checkout

#   endpoint_id=$(echo "$out" | jq -r '.value[].id')

# # make payload for the POST request
# # /bin/cat <<END >params.json
# # {
# #   "agentInteractiveUI": false,
# #   "azureId": "$AZ_VMSS_ID",
# #   "desiredIdle": $ADO_POOL_DESIRED_IDLE,
# #   "desiredSize": $ADO_POOL_DESIRED_SIZE,
# #   "maxCapacity": $ADO_POOL_MAX_CAPACITY,
# #   "maxSavedNodeCount": $ADO_POOL_MAX_SAVED_NODE_COUNT,
# #   "offlineSince": "",
# #   "osType": "linux",
# #   "recycleAfterEachUse": $ADO_POOL_RECYCLE_AFTER_USE,
# #   "serviceEndpointId": "$endpoint_id",
# #   "serviceEndpointScope": "$project_id",
# #   "sizingAttempts": $ADO_POOL_SIZING_ATTEMPTS,
# #   "state": "online",
# #   "timeToLiveMinutes": $ADO_POOL_TTL_MINS
# # }
# # END

#   printf "ADO_POOL_NAME: %s\n" "$ADO_POOL_NAME"
#   printf "ADO_POOL_AUTH_ALL_PIPELINES: %s\n" "$ADO_POOL_AUTH_ALL_PIPELINES"
#   printf "ADO_POOL_AUTO_PROVISION: %s\n" "$ADO_POOL_AUTO_PROVISION"
#   printf "project_id: %s\n" "$project_id"
#   # https://learn.microsoft.com/en-us/rest/api/azure/devops/distributedtask/elasticpools/create?view=azure-devops-rest-7.1
#   if [ "$ADO_PROJECT_ONLY" = "True" ]
#   then
#     poolUrl="${ADO_ORG}/_apis/distributedtask/elasticpools?poolName=${ADO_POOL_NAME}&authorizeAllPipelines=${ADO_POOL_AUTH_ALL_PIPELINES}&autoProvisionProjectPools=${ADO_POOL_AUTO_PROVISION}&projectId=${project_id}&api-version=7.1-preview.1"
#   else
#     poolUrl="${ADO_ORG}/_apis/distributedtask/elasticpools?poolName=${ADO_POOL_NAME}&authorizeAllPipelines=${ADO_POOL_AUTH_ALL_PIPELINES}&autoProvisionProjectPools=${ADO_POOL_AUTO_PROVISION}&api-version=7.1-preview.1"
#   fi
#   printf "poolUrl: %s\n" "$poolUrl"

#   curlwithcode "POST" "$poolUrl"
#   checkout

#   # cleanup
#   rm params.json

#   # https://learn.microsoft.com/en-us/rest/api/azure/devops/distributedtask/elasticpools/get?view=azure-devops-rest-7.1

#   poolId=$(echo "$out" | jq -r .elasticPool.poolId)
#   poolUrl="${ADO_ORG}/_apis/distributedtask/elasticpools/${poolId}?api-version=7.1-preview.1"

#   curlwithcode "GET" "$poolUrl"
#   checkout

#   printf "poolId: %s\n" "$poolId"
#   printf "poolUrl: %s\n" "$poolUrl"

#   # this will be what gets saved to state
#   printf "%s" "$out" | jq -r 'del(.offlineSince, .state)'
# fi


# if [ "$mode" = "update" ]
# then
#   IN=$(cat)
#   echo "UPDATE_IN: $IN"
#   AZ_VMSS_ID=$(echo "$IN" | jq -r '.azureId')
#   endpoint_id=$(echo "$IN" | jq -r '.serviceEndpointId')
#   project_id=$(echo "$IN" | jq -r '.serviceEndpointScope')
#   pool_id=$(echo "$IN" | jq -r '.poolId')
#   echo "pool_id: $pool_id"
#   echo "AZ_VMSS_ID: $AZ_VMSS_ID"
#   echo "endpoint_id: $endpoint_id"
#   echo "project_id: $project_id"

# # make payload for the PATCH request
# /bin/cat <<END >params.json
# {
#   "agentInteractiveUI": false,
#   "azureId": "$AZ_VMSS_ID",
#   "desiredIdle": $ADO_POOL_DESIRED_IDLE,
#   "maxCapacity": $ADO_POOL_MAX_CAPACITY,
#   "maxSavedNodeCount": $ADO_POOL_MAX_SAVED_NODE_COUNT,
#   "osType": "linux",
#   "recycleAfterEachUse": $ADO_POOL_RECYCLE_AFTER_USE,
#   "serviceEndpointId": "$endpoint_id",
#   "serviceEndpointScope": "$project_id",
#   "timeToLiveMinutes": $ADO_POOL_TTL_MINS
# }
# END

#   # https://learn.microsoft.com/en-us/rest/api/azure/devops/distributedtask/elasticpools/update?view=azure-devops-rest-7.1
#   poolUrl="${ADO_ORG}/_apis/distributedtask/elasticpools/$pool_id?api-version=7.1-preview.1"

#   # do PATCH
#   resp=$(curl \
#     --silent \
#     --show-error \
#     --header "Content-Type: application/json" \
#     --request PATCH \
#     --user ":$AZURE_DEVOPS_EXT_PAT" \
#     --data @params.json \
#     "$poolUrl")

#   # cleanup
#   rm params.json

#   # do GET - this will be what gets saved to state
#   poolUrl="${ADO_ORG}/_apis/distributedtask/elasticpools/$pool_id?api-version=7.1-preview.1"

#   echo "$pool_id"
#   resp=$(curl \
#     --silent \
#     --show-error \
#     --header "Content-Type: application/json" \
#     --request GET \
#     --user ":$AZURE_DEVOPS_EXT_PAT" \
#     "$poolUrl")

#   printf "%s" "$resp" | jq -r 'del(.offlineSince, .state)'
# fi


# if [ "$mode" = "delete" ]
# then

#   # GET https://dev.azure.com/{organization}/_apis/distributedtask/pools?api-version=6.0
#   poolUrl="$ADO_ORG/_apis/distributedtask/pools?api-version=6.0"

#   resp=$(curl \
#     --silent \
#     --show-error \
#     --header "Content-Type: application/json" \
#     --request GET \
#     --user ":$AZURE_DEVOPS_EXT_PAT" \
#     "$poolUrl")

#   pool=$(printf "%s" "$resp" | jq -r --arg name "$ADO_POOL_NAME" '.value[] | select (.name==$name)')
#   echo "$pool"

#   pool_id=$(echo "$pool" | jq -r '.id')
#   echo "pool_id: $pool_id"

#   if [ -z "$pool_id" ]
#   then
#     echo "failed to get pool_id to delete"
#     exit 1
#   fi

#   # DELETE https://dev.azure.com/{organization}/_apis/distributedtask/pools/{poolId}?api-version=7.1-preview.1
#   poolUrl="$ADO_ORG/_apis/distributedtask/pools/$pool_id?api-version=7.1-preview.1"

#   resp=$(curl \
#     --silent \
#     --show-error \
#     --header "Content-Type: application/json" \
#     --request DELETE \
#     --user ":$AZURE_DEVOPS_EXT_PAT" \
#     "$poolUrl")

# fi

# shellcheck source=./scripts/functions.sh
source ./scripts/functions.sh
mode="$1"
main
