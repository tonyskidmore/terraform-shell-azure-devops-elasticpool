
source ~/.azdo_rc

https://github.com/janderssonse/ort-ci-base/blob/01445247f5b88b06d51d4e6b218ba26dd12bda56/test/install_bats.bash

https://github.com/melita-ita-dev/jx-custom-terraform-module-with-existing-cluster/tree/master


https://bats-core.readthedocs.io/en/stable/tutorial.html#quick-installation

git submodule add https://github.com/bats-core/bats-core.git test/bats
git submodule add https://github.com/bats-core/bats-support.git test/test_helper/bats-support
git submodule add https://github.com/bats-core/bats-assert.git test/test_helper/bats-assert


./test/bats/bin/bats test/test.bats
