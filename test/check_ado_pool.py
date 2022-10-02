""" Helper script for calling get_ado_pool """

import os

from ado.get_ado_pool import get_ado_pool

org = os.environ['TF_VAR_ado_org']
pool_id = os.environ['TF_VAR_pool_id']
pat = os.environ['TF_VAR_ado_ext_pat']

resp = get_ado_pool(org, pool_id, pat)
print(resp)
