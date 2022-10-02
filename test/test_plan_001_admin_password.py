""" Test init and apply using admin password configuration. """

import os

import pytest

# fixtures_dir = os.path.join(os.path.dirname(__file__), 'default')
fixtures_dir = os.path.join(os.path.dirname(os.path.abspath(__file__)),
                            'fixtures')


# def assert_resource_changes_action(resource_changes, action, length):
#     resource_changes_create = [
#         value for _, value in resource_changes.items()
#         if value.get('change').get('actions') == [action]
#     ]
#     assert len(resource_changes_create) == length


# def assert_resource_changes(testname, resource_changes):
#     with open(f'test/modules/route53-dns/files/{testname}.json', 'r') as f:
#         data = json.load(f)
#         i = 0
#         for _, value in resource_changes.items():
#             assert sorted(data.get('resource_changes')[i]) == sorted(value)
#             i=+1

@pytest.fixture(scope='module', name="tf_plan_resources")
def plan_resources(plan_runner):
    """ Terraform plan runner fixture """

    target = "module.terraform-azurerm-vmss-devops-agent"
    tfvars = "admin_password.tfvars"
    plan, resources = plan_runner('default',
                                  targets=[target],
                                  tf_var_file=os.path.join(fixtures_dir,
                                                           tfvars))

    return plan, resources


def test_admin_password(tf_plan_resources):
    """ Test that the admin_password matches that defined in the variables. """

    plan, resources = tf_plan_resources

    vmss_res_pwd = resources[0]['values']['admin_password']
    vmss_plan_pwd = plan.variables['vmss_admin_password']

    assert vmss_res_pwd == vmss_plan_pwd


def test_password_authentication(tf_plan_resources):
    """ Test that disable_password_authentication is not enabled. """

    _, resources = tf_plan_resources
    vmss = resources[0]

    assert vmss['values']['disable_password_authentication'] is False


def test_admin_ssh_key(tf_plan_resources):
    """ Test that the admin_ssh_key is empty. """

    _, resources = tf_plan_resources
    vmss = resources[0]

    assert len(vmss['values']['admin_ssh_key']) == 0


def test_identity(tf_plan_resources):
    """ Test that a SystemAssigned identity is not set. """

    _, resources = tf_plan_resources
    vmss = resources[0]

    assert vmss['values']['identity'] == []


def test_planned_vmss_changes(tf_plan_resources):
    """ Test expected plan resource changes. """

    plan, _ = tf_plan_resources

    module_ref = ("module.terraform-azurerm-vmss-devops-agent."
                  "azurerm_linux_virtual_machine_scale_set.ado_pool[0]")

    resource_changes = plan.resource_changes[module_ref]
    assert resource_changes['change']['before'] is None
    assert len(resource_changes['change']['after']) >= 43
