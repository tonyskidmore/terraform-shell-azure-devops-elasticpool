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
    printf "status: %s\n" "$status"  >&2
    printf "%s\n" "$out"
    exit 1
  fi

}

# end functions

std_in=$(cat)
printf "std_in: %s\n" "$std_in"
poolId=$(echo "$std_in" | jq -r '.poolId')
printf "poolId: %s\n" "$poolId"

# https://learn.microsoft.com/en-us/rest/api/azure/devops/distributedtask/elasticpools/get?view=azure-devops-rest-7.1
poolUrl="$ADO_ORG/_apis/distributedtask/elasticpools/${poolId}?api-version=7.1-preview.1"

curlwithcode "GET" "$poolUrl"
checkout

printf "%s" "$out" | jq -r 'del(.offlineSince, .state)'
