""" pytest configuration module. """

import os

import pytest
import tftest

BASEDIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'fixtures')

# setup parametr defaulst to True
# cleanup_on_exit=False

# @pytest.fixture(scope='session')
# def _plan_apply_runner():
#     "Returns a function to run Terraform plan and apply on a fixture."

#     # with tempfile.NamedTemporaryFile() as fp:
#     #   fp.close()

#     def run_plan(fixture_path, targets=None, refresh=True,
#                  tf_var_file=None, tf_vars=None, **kw):
#         """ Runs Terraform plan and apply and returns parsed output. """
#         tf_test = tftest.TerraformTest(fixture_path, BASEDIR,
#                                        os.environ.get('TERRAFORM',
#                                                       'terraform'))
#         tf_test.setup()
#         return tf_test.plan(output=False, refresh=refresh, tf_vars=tf_vars,
#                             targets=targets, tf_var_file=tf_var_file)
#     return run_plan


# @pytest.fixture(scope='session')
# def plan_runner(_plan_runner):
#     """ Returns a function to run Terraform plan on a module fixture. """

#     def run_plan(fixture_path, targets=None, tf_var_file=None, **tf_vars):
#         """ Runs Terraform plan and returns plan and module resources. """
#         plan = _plan_runner(fixture_path, targets=targets,
#                             tf_var_file=tf_var_file, **tf_vars)

#         root_module = plan.root_module['child_modules'][0]
#         return plan, root_module['resources']

#     return run_plan

@pytest.fixture(scope='session')
def _plan_runner():
    "Returns a function to run Terraform plan on a fixture."

    def run_plan(fixture_path, targets=None, refresh=True,
                 tf_var_file=None, **tf_vars):
        """ Runs Terraform plan and returns parsed output. """
        tf_test = tftest.TerraformTest(fixture_path, BASEDIR,
                                       os.environ.get('TERRAFORM',
                                                      'terraform'))
        tf_test.setup(cleanup_on_exit=False)
        return tf_test.plan(output=True, refresh=refresh, tf_vars=tf_vars,
                            targets=targets, tf_var_file=tf_var_file)
    return run_plan


@pytest.fixture(scope='session')
def plan_runner(_plan_runner):
    """ Returns a function to run Terraform plan on a module fixture. """

    def run_plan(fixture_path, targets=None, tf_var_file=None, **tf_vars):
        """ Runs Terraform plan and returns plan and module resources. """
        plan = _plan_runner(fixture_path, targets=targets,
                            tf_var_file=tf_var_file, **tf_vars)

        root_module = plan.root_module['child_modules'][0]
        return plan, root_module['resources']

    return run_plan


@pytest.fixture(scope='session')
def plan_apply_runner():
    """ Returns a function to run Terraform plan and apply
    on a module fixture. """

    def run_play_apply(fixture_path,
                       targets=None,
                       refresh=True,
                       tf_var_file=None, **tf_vars):
        """ Runs Terraform plan and applt and returns parsed output. """

        tf_test = tftest.TerraformTest(fixture_path, BASEDIR,
                                       os.environ.get('TERRAFORM',
                                                      'terraform'))
        tf_test.setup(cleanup_on_exit=False)
        plan = tf_test.plan(output=True, refresh=refresh, tf_vars=tf_vars,
                            targets=targets, tf_var_file=tf_var_file)
        apply = tf_test.apply(tf_vars=tf_vars, tf_var_file=tf_var_file)
        output = tf_test.output(json_format=True)

        return plan, apply, output

    return run_play_apply


@pytest.fixture(scope='session')
def e2e_plan_runner(_plan_runner):
    """ Returns a function to run Terraform plan on an end-to-end fixture. """

    def run_plan(fixture_path, targets=None, refresh=True,
                 tf_var_file=None, **tf_vars):
        """ Runs Terraform plan on an end-to-end module using defaults. """
        plan = _plan_runner(fixture_path, targets=targets, refresh=refresh,
                            tf_var_file=tf_var_file, **tf_vars)
        # skip the fixture
        root_module = plan.root_module['child_modules'][0]
        modules = dict((mod['address'], mod['resources'])
                       for mod in root_module['child_modules'])
        resources = [r for m in modules.values() for r in m]
        return plan, modules, resources

    return run_plan


@pytest.fixture(scope='session')
def example_plan_runner(_plan_runner):
    """ Returns a function to run Terraform plan on documentation examples. """

    def run_plan(fixture_path):
        """ Runs Terraform plan and returns count of modules and resources. """
        plan = _plan_runner(fixture_path)
        # the fixture is the example we are testing
        return (
            len(plan.modules),
            sum(len(m.resources) for m in plan.modules.values()))

    return run_plan


@pytest.fixture(scope='session')
def apply_runner():
    """ Returns a function to run Terraform apply on a fixture. """

    def run_apply(fixture_path, tf_var_file=None, **tf_vars):
        """ Runs Terraform apply and returns parsed output. """

        tf_test = tftest.TerraformTest(fixture_path, BASEDIR,
                                       os.environ.get('TERRAFORM',
                                                      'terraform'))
        tf_test.setup(cleanup_on_exit=False)
        apply = tf_test.apply(tf_vars=tf_vars, tf_var_file=tf_var_file)
        output = tf_test.output(json_format=True)
        return apply, output

    return run_apply


@pytest.fixture(scope='session')
def destroy_runner():
    """ Returns a function to run Terraform destroy on a fixture. """

    def run_destroy(fixture_path, tf_var_file=None, **tf_vars):
        """ Runs Terraform destroy and returns parsed output. """

        tf_test = tftest.TerraformTest(fixture_path, BASEDIR,
                                       os.environ.get('TERRAFORM',
                                                      'terraform'))
        tf_test.setup(cleanup_on_exit=True)
        output = tf_test.destroy(tf_vars=tf_vars, tf_var_file=tf_var_file,
                                 **{"auto_approve": True})
        return output

    return run_destroy
