#!/bin/bash

# set -ex
# https://www.howtogeek.com/782514/how-to-use-set-and-pipefail-in-bash-scripts-on-linux/
# set -eou pipefail
set -eu

# GET https://dev.azure.com/{organization}/_apis/distributedtask/pools?api-version=6.0
poolUrl="$ADO_ORG/_apis/distributedtask/pools?api-version=6.0"

resp=$(curl \
  --silent \
  --show-error \
  --header "Content-Type: application/json" \
  --request GET \
  --user ":$AZURE_DEVOPS_EXT_PAT" \
  "$poolUrl")

pool=$(printf "%s" "$resp" | jq -r --arg name "$ADO_POOL_NAME" '.value[] | select (.name==$name)')
echo "$pool"

pool_id=$(echo "$pool" | jq -r '.id')
echo "pool_id: $pool_id"

if [ -z "$pool_id" ]
then
  echo "failed to get pool_id to delete"
  exit 1
fi

# DELETE https://dev.azure.com/{organization}/_apis/distributedtask/pools/{poolId}?api-version=7.1-preview.1
poolUrl="$ADO_ORG/_apis/distributedtask/pools/$pool_id?api-version=7.1-preview.1"

resp=$(curl \
  --silent \
  --show-error \
  --header "Content-Type: application/json" \
  --request DELETE \
  --user ":$AZURE_DEVOPS_EXT_PAT" \
  "$poolUrl")
