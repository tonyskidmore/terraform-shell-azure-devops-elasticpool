#!/bin/bash

# set -ex
# https://www.howtogeek.com/782514/how-to-use-set-and-pipefail-in-bash-scripts-on-linux/
# set -eou pipefail
set -eu

# GET https://dev.azure.com/{organization}/_apis/distributedtask/elasticpools/{poolId}?api-version=7.1-preview.1

IN=$(cat)
echo "READ_IN: $IN"
pool_id=$(echo "$IN" | jq -r '.poolId')
echo "pool_id: $pool_id"

poolUrl="$ADO_ORG/_apis/distributedtask/elasticpools/$pool_id?api-version=7.1-preview.1"

resp=$(curl \
  --silent \
  --show-error \
  --header "Content-Type: application/json" \
  --request GET \
  --user ":$AZURE_DEVOPS_EXT_PAT" \
  "$poolUrl")

printf "%s" "$resp" | jq -r 'del(.offlineSince, .state)'
