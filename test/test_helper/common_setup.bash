# export ADO_ORG="https://dev/azure.com/tonyskidmore"
# export ADO_POOL_AUTH_ALL_PIPELINES="True"
# export ADO_POOL_AUTO_PROVISION="True"
# export ADO_POOL_DESIRED_IDLE=0
# export ADO_POOL_DESIRED_SIZE=0
# export ADO_POOL_MAX_CAPACITY=2
# export ADO_POOL_MAX_SAVED_NODE_COUNT=0
# export ADO_POOL_NAME="vmss-mkt-image-099"
# export ADO_POOL_OS_TYPE="linux"
# export ADO_POOL_RECYCLE_AFTER_USE="false"
# export ADO_POOL_SIZING_ATTEMPTS=0
# export ADO_POOL_TTL_MINS=30
# export ADO_PROJECT="ve-vmss"
# export ADO_PROJECT_ONLY="false"
# export ADO_SERVICE_CONNECTION="ve-vmss"
# export AZ_VMSS_ID="/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-vmss-azdo-agents-01/providers/Microsoft.Compute/virtualMachineScaleSets/vmss-portal-test-001"
# export AZURE_DEVOPS_EXT_PAT="dummypat"

_common_setup() {
    load 'test_helper/bats-support/load'
    load 'test_helper/bats-assert/load'
    # get the containing directory of this file
    # use $BATS_TEST_FILENAME instead of ${BASH_SOURCE[0]} or $0,
    # as those will point to the bats executable's location or the preprocessed file respectively
    DIR="$( cd "$( dirname "$BATS_TEST_FILENAME" )" >/dev/null 2>&1 && pwd )"
    # make executables in scripts/ visible to PATH
    PATH="$DIR/../scripts:$PATH"

    # source functions.sh
    # shellcheck disable=SC1091
    source ado_elastic_pool.sh
}
