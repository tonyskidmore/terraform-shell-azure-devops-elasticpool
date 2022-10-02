""" Test init and apply using admin password configuration. """

import logging
import os
import sys

import pytest

# import re
# import sys
# import json
# import tftest
# https://stackoverflow.com
# /questions/43960681/how-to-import-using-a-path-that-is-a-variable-in-python

fixtures_dir = os.path.join(os.path.dirname(os.path.abspath(__file__)),
                            'fixtures')
test_dir = os.path.dirname(fixtures_dir)
tf_var_file = os.path.join(fixtures_dir, 'admin_password.tfvars')

sys.path.append(test_dir)
# pylint: disable=C0413
from ado.get_ado_pool import get_ado_pool  # noqa: E402

# @pytest.fixture(scope='module', name="tf_plan")
# def plan_resources(plan_runner):
#     """ Terraform plan runner fixture """

#     target = "module.terraform-azurerm-vmss-devops-agent"
#     tfvars = "admin_password.tfvars"
#     plan, resources = plan_runner('default',
#                                   targets=[target],
#                                   tf_var_file=os.path.join(fixtures_dir,
#                                                            tfvars))

#     return plan, resources


# @pytest.fixture(scope='module', name="tftest_apply")
# def apply(apply_runner):
#     """ Terraform apply runner fixture """

#     tf_apply, tf_output = apply_runner('default', tf_var_file=tf_var_file)
#     return tf_apply, tf_output


@pytest.fixture(scope='module', name="tftest_plan_apply")
def plan_apply(plan_apply_runner):
    """ Terraform plan and apply runner fixture """

    tf_plan, tf_apply, tf_output = plan_apply_runner('default',
                                                     tf_var_file=tf_var_file)
    return tf_plan, tf_apply, tf_output


@pytest.fixture(scope='module', name="tftest_destroy")
def destroy(destroy_runner):
    """ Terraform destroy runner fixture """

    tf_destroy = destroy_runner('default', tf_var_file=tf_var_file)

    return tf_destroy


# def test_apply_os_type( tftest_apply):
#     """ Test that the osType equals linux. """

#     _, tf_output = tftest_apply

#     ado_pool = tf_output['ado_vmss_pool_output']

#     assert ado_pool['osType'] == 'linux'


# @pytest.fixture(scope="module")
# def output(fixtures_dir):
#     tf = tftest.TerraformTest('default', fixtures_dir)
#     # tf.setup()
#     tf.setup(extra_files=['admin_password.tfvars'])
#     # tf.apply()
#     # yield tf.output()
#     tf.destroy(**{"auto_approve": True})


def test_ado_pool(tftest_plan_apply):
    """ Test that the created ADO ElasticPool. """

    tf_plan, _, tf_output = tftest_plan_apply

    logging.info(test_dir)

    output_keys = tf_output.keys()
    logging.info(output_keys)

    ado_org = tf_plan.variables['ado_org']
    ado_pat = tf_plan.variables['ado_ext_pat']
    try:
        output_pool_id = tf_output['ado_vmss_pool_output']['poolId']
        ado_pool_id = int(output_pool_id)
    except ValueError:
        print(f"{output_pool_id} is not a valid integer.")

    status_code, pool_settings = get_ado_pool(ado_org,
                                              ado_pool_id,
                                              ado_pat)

    assert status_code == 200
    assert pool_settings['poolId'] == ado_pool_id
    assert pool_settings['maxCapacity'] == 2
    assert pool_settings['desiredIdle'] == 0
    assert pool_settings['recycleAfterEachUse'] is False
    assert pool_settings['maxSavedNodeCount'] == 0
    assert pool_settings['osType'] == 'linux'
    assert pool_settings['desiredSize'] == 0
    assert pool_settings['sizingAttempts'] == 0
    assert pool_settings['timeToLiveMinutes'] == 30


# Resources: 2 destroyed
def test_destroy(tftest_destroy):
    """ Test destroy output for expected results. """

    assert 'Resources: 2 destroyed' in tftest_destroy


# @pytest.fixture(scope="module")
# def output(fixtures_dir):
#     tf = tftest.TerraformTest('default', fixtures_dir)
#     # tf.setup()
#     tf.setup(extra_files=['admin_password.tfvars'])
#     tf.apply()
#     yield tf.output()
#     tf.destroy(**{"auto_approve": True})


# def import_ado(fixtures_dir):
#     sys.path.append(fixtures_dir)
#     from ado.get_ado_pool import get_ado_pool

# def test_apply(output):
#     print(output)
#     value = output['vmss_system_assigned_identity_id']
#     regex = "^[{]?[0-9a-fA-F]{8}-([0-9a-fA-F]{4}-){3}[0-9a-fA-F]{12}[}]?$"
#     print(value)
#     p = re.compile(regex)
#     assert re.search(p, value)

# def test_pool(plan, output):
#     sys.path.append(fixtures_dir)
#     from ado.get_ado_pool import get_ado_pool
#     pool_output = output['ado_vmss_pool_output']
#     pool_settings = get_ado_pool(plan.variables['ado_org'],
#                                  output['poolId'],
#                                  plan.variables['ado_ext_pat'])
#     assert pool_settings['poolId'] == pool_output['poolId']
