""" Gets settings of an Azure DevOps ElasticPool. """

# export TF_VAR_ado_org="https://dev.azure.com/tonyskidmore"
# export TF_VAR_pool_id="47"
# export TF_VAR_ado_ext_pat="$AZURE_DEVOPS_EXT_PAT"

import os

import requests
from requests.auth import HTTPBasicAuth


def get_ado_pool(org, pool_id, pat):
    """ Get Azure DevOps pool settings. """

    api_url = (
        f"{org}/_apis/distributedtask/elasticpools/"
        f"{pool_id}?api-version=7.1-preview.1"
    )

    headers = {'Accept': 'application/json'}

    try:
        response = requests.get(api_url, headers=headers,
                                auth=HTTPBasicAuth('', pat),
                                timeout=10)
        response.raise_for_status()
    except requests.exceptions.HTTPError as errh:
        print("Http Error:", errh)
    except requests.exceptions.ConnectionError as errc:
        print("Error Connecting:", errc)
    except requests.exceptions.Timeout as errt:
        print("Timeout Error:", errt)
    except requests.exceptions.RequestException as err:
        print("Requests Exception Error", err)

    return response.status_code, response.json()


def main():
    """ main function. """

    try:
        org = os.environ['TF_VAR_ado_org']
        pool_id = os.environ['TF_VAR_pool_id']  # output.poolId
        pat = os.environ['TF_VAR_ado_ext_pat']
    except KeyError as err:
        print("An error occurred:", err)
        raise err

    _, pool_settings = get_ado_pool(org, pool_id, pat)
    print(pool_settings)


if __name__ == "__main__":
    main()
