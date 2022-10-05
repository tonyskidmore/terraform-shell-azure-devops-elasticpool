#!/bin/sh

set -eu

IN=$(cat)
echo "UPDATE_IN: $IN"
AZ_VMSS_ID=$(echo "$IN" | jq -r '.azureId')
endpoint_id=$(echo "$IN" | jq -r '.serviceEndpointId')
project_id=$(echo "$IN" | jq -r '.serviceEndpointScope')
pool_id=$(echo "$IN" | jq -r '.poolId')
echo "pool_id: $pool_id"
echo "AZ_VMSS_ID: $AZ_VMSS_ID"
echo "endpoint_id: $endpoint_id"
echo "project_id: $project_id"

# make payload for the PATCH request
/bin/cat <<END >params.json
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
END

# https://learn.microsoft.com/en-us/rest/api/azure/devops/distributedtask/elasticpools/update?view=azure-devops-rest-7.1
poolUrl="${ADO_ORG}/_apis/distributedtask/elasticpools/$pool_id?api-version=7.1-preview.1"

# do PATCH
resp=$(curl \
  --silent \
  --show-error \
  --header "Content-Type: application/json" \
  --request PATCH \
  --user ":$AZURE_DEVOPS_EXT_PAT" \
  --data @params.json \
  "$poolUrl")

# cleanup
rm params.json

# do GET - this will be what gets saved to state
poolUrl="${ADO_ORG}/_apis/distributedtask/elasticpools/$pool_id?api-version=7.1-preview.1"

echo "$pool_id"
resp=$(curl \
  --silent \
  --show-error \
  --header "Content-Type: application/json" \
  --request GET \
  --user ":$AZURE_DEVOPS_EXT_PAT" \
  "$poolUrl")

printf "%s" "$resp" | jq -r 'del(.offlineSince, .state)'
