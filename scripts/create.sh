#!/bin/bash

# set -ex
# https://www.howtogeek.com/782514/how-to-use-set-and-pipefail-in-bash-scripts-on-linux/
# set -eou pipefail
# set -eu
# set -u

curlwithcode() {
    status=0
    # Run curl in a separate command, capturing output of -w "%{http_code}" into statuscode
    # and sending the content to a file with -o >(cat >/tmp/curl_body)
    http_code=$(curl \
                 --silent \
                 --show-error \
                 --write-out '%{http_code}' \
                 --header "Content-Type: application/json" \
                 --request POST \
                 --user ":$AZURE_DEVOPS_EXT_PAT" \
                 --data @params.json \
                 --output /tmp/curl_body \
                 "$poolUrl"
    ) || status="$?"

    out="$(cat /tmp/curl_body)"
    # out=$(</tmp/curl_body)
}

# GET https://dev.azure.com/fabrikam/_apis/projects?api-version=6.0
projectUrl="$ADO_ORG/_apis/projects?api-version=6.0"

resp=$(curl \
  --silent \
  --show-error \
  --header "Content-Type: application/json" \
  --request GET \
  --user ":$AZURE_DEVOPS_EXT_PAT" \
  "$projectUrl")

printf "project resp: %s\n"  "$resp"

project=$(printf "%s" "$resp" | jq -r --arg name "$ADO_PROJECT" '.value[] | select (.name==$name)')
project_id=$(echo "$project" | jq -r '.id')


# GET https://dev.azure.com/{organization}/{project}/_apis/serviceendpoint/endpoints?endpointNames=MyNewServiceEndpoint&api-version=6.0-preview.4
endpointUrl="$ADO_ORG/$ADO_PROJECT/_apis/serviceendpoint/endpoints?endpointNames=$ADO_SERVICE_CONNECTION&api-version=6.0-preview.4"
resp=$(curl \
  --silent \
  --show-error \
  --header "Content-Type: application/json" \
  --request GET \
  --user ":$AZURE_DEVOPS_EXT_PAT" \
  "$endpointUrl")

printf "endpoint resp: %s\n"  "$resp"

endpoint_id=$(echo "$resp" | jq -r '.value[].id')

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
# https://learn.microsoft.com/en-us/rest/api/azure/devops/distributedtask/elasticpools/create?view=azure-devops-rest-7.1
poolUrl="${ADO_ORG}/_apis/distributedtask/elasticpools?poolName=${ADO_POOL_NAME}&authorizeAllPipelines=${ADO_POOL_AUTH_ALL_PIPELINES}&autoProvisionProjectPools=${ADO_POOL_AUTO_PROVISION}&projectId=${project_id}&api-version=7.1-preview.1"

# do POST
resp=$(curl \
  --silent \
  --show-error \
  --header "Content-Type: application/json" \
  --request POST \
  --user ":$AZURE_DEVOPS_EXT_PAT" \
  --data @params.json \
  "$poolUrl")

printf "pool create resp: %s\n"  "$resp"

# cleanup
# rm params.json

# GET https://dev.azure.com/{organization}/_apis/distributedtask/elasticpools/{poolId}?api-version=7.1-preview.1
# do GET - this will be what gets saved to state
poolId=$(echo "$resp" | jq -r .elasticPool.poolId)
poolUrl="${ADO_ORG}/_apis/distributedtask/elasticpools/${poolId}?api-version=7.1-preview.1"

# Curl to return http status code along with the response
# https://stackoverflow.com/questions/38906626/curl-to-return-http-status-code-along-with-the-response#:~:text=Curl%20allows%20you%20to%20customize%20output.%20You%20can,the%20response%20is%20worth%20printing%2C%20processing%2C%20logging%2C%20etc.
echo "$poolId"
# resp=$(curl \
#   --silent \
#   --show-error \
#   --header "Content-Type: application/json" \
#   --request GET \
#   --user ":$AZURE_DEVOPS_EXT_PAT" \
#   "$poolUrl")

# printf "pool get resp: %s\n"  "$resp"

# {
#   IFS= read -rd '' out
#   IFS= read -rd '' http_code
#   IFS= read -rd '' status
# } < <({ out=$(curl \
#               --silent \
#               --show-error \
#               --output /dev/stderr \
#               -w "%{http_code}" \
#               --header "Content-Type: application/json" \
#               --request POST \
#               --user ":$AZURE_DEVOPS_EXT_PAT" \
#               --data @params.json $poolUrl)
#       } 2>&1; printf '\0%s' "$out" "$?")

curlwithcode

printf "out: %s\n" "$out"
printf "http_code: %s\n" "$http_code"
printf "status: %s\n" "$status"

# if jq -e . <<<"$out"; then
if [ "$(echo "$out" | jq empty > /dev/null 2>&1; echo $?)" == "0" ]
then
  echo "Parsed JSON successfully and got something other than false/null"
  declare -A env_vars

  # loop through key/value using to_entries to add entries to associative array
  json=$(echo "$out" | jq -r '. | to_entries | .[] | .key + "=" + (.value|tostring)')
  while IFS=":" read -r key value; do
    env_vars["$key"]="$value"
  # done < <(jq -r '. | to_entries | .[] | .key + "=" + .value' <<< "${out}")
  # done < <(echo "$out" | jq -r '. | to_entries | .[] | .key + "=" + (.value|tostring)')
  done < "$json"
  declare -p env_vars

  for key in "${!env_vars[@]}"; do
    key="${key//\$/}"
    echo "$key ${env_vars[$key]}"
    export "$key"="${env_vars[$key]}"
  done
else
  printf "{%s} Failed to parse JSON, or got false/null.\n" "$(date)" >&2
  exit 1
fi

# message is assigned parsing error output above
# shellcheck disable=SC2154
printf "message: %s\n" "$message"

# remove_fields "$resp"
printf "%s" "$resp" | jq -r 'del(.offlineSince, .state)'
