# export TF_VAR_ado_ext_pat="$AZURE_DEVOPS_EXT_PAT"
# do the same for others e.g. org
# make all inputs variables and use tfvars

# https://code.visualstudio.com/docs/python/environments#_environment-variable-definitions-file
# https://code.visualstudio.com/docs/python/testing
# https://code.visualstudio.com/docs/python/environments

WSL

conda activate tftest

source ~/.azdo_rc



MS Terminal
WSL
conda activate tftest_20220910
cd /mnt/c/Users/tonys/Documents/GitHub/azurerm-terraform-azdo-linux-vmss
code .

make test_plan
make test_apply

__Note:__ environment variables are loaded from .env file excluded from repo in .gitignore - only for test loads?
AZURE_DEVOPS_EXT_PAT="my-secret-pat"
TF_VAR_ado_org="https://dev.azure.com/tonyskidmore"
TF_VAR_ado_ext_pat="my-secret-pat"
