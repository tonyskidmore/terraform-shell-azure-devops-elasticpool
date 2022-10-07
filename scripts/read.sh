#!/bin/sh

set -eu

IN=$(cat)
echo "READ_IN: $IN"
pool_id=$(echo "$IN" | jq -r '.poolId')
echo "pool_id: $pool_id"

# https://learn.microsoft.com/en-us/rest/api/azure/devops/distributedtask/elasticpools/get?view=azure-devops-rest-7.1
poolUrl="$ADO_ORG/_apis/distributedtask/elasticpools/$pool_id?api-version=7.1-preview.1"

resp=$(curl \
  --silent \
  --show-error \
  --header "Content-Type: application/json" \
  --request GET \
  --user ":$AZURE_DEVOPS_EXT_PAT" \
  "$poolUrl")

printf "%s" "$resp" | jq -r 'del(.offlineSince, .state)'
