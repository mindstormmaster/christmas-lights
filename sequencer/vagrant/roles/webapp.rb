# webapp server role
#
#
name "webapp"
description "Configure vagrant webapp"

run_list "recipe[vagrant_webapp]",
    "recipe[vagrant_webapp::opsworks_db]",
    "recipe[vagrant_webapp::database]",
    "recipe[vagrant_webapp::before_symlink]"
