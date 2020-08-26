include {
  #path = find_in_parent_folders("abcd.hcl")
  path = "${find_in_parent_folders()}"

}

terraform {

  #source = "git::ssh://git@gilligan.pearsondev.com/tms/modules.git//rds-mysql-smk?ref=master"
  source = "../../../../modules//rds-mysql-smk?ref=master"

  extra_arguments "variables" {
    arguments = [
      "-var=aws_account_id=${get_aws_account_id()}"
    ]

    #commands = ["${get_terragrunt_commands_that_need_vars()}"]
    commands = [
            "apply",
            "destroy",
            "plan",
            "import",
            "push",
            "refresh"
          ]
    required_var_files = [
      "${get_terragrunt_dir()}/../general.tfvars"
    ]

    optional_var_files = [
      "${get_terragrunt_dir()}/../secure.tfvars"
    ]
  }
}

dependencies {
  paths = ["../network-aiprimary"]
}
