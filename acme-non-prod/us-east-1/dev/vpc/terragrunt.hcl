#--------------------------------------
# Terragrunt config
#--------------------------------------
include {
  path = find_in_parent_folders()
}

terraform {
  source = "git@github.com:tnasirov/terraform-modules.git//tf-aws-vpc?ref=main"
}

inputs = {
  create_vpc = true

  vpc_name = "acme-dev"
  cidr     = "10.16.0.0/16"

  public_subnets   = ["10.16.0.0/21", "10.16.8.0/21", "10.16.16.0/21"]      # reserved 10.16.24.0/21
  private_subnets  = ["10.16.32.0/19", "10.16.64.0/19", "10.16.96.0/19"]    # reserved 10.16.128.0/19
  database_subnets = ["10.16.160.0/23", "10.16.162.0/23", "10.16.164.0/23"] # reserved 10.16.166.0/23
}
