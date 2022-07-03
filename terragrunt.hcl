# ---------------------------------------------------------------------------------------------------------------------
# TERRAGRUNT CONFIGURATION
# Terragrunt is a thin wrapper for Terraform that provides extra tools for working with multiple Terraform modules,
# remote state, and locking: https://github.com/gruntwork-io/terragrunt
# ---------------------------------------------------------------------------------------------------------------------

locals {

  # Automatically load region-level variables
  region_vars = read_terragrunt_config("region.hcl", read_terragrunt_config(find_in_parent_folders("region.hcl", "does-not-exist.fallback"), { locals = {} }))

  # Automatically load environment-level variables
  env_vars = read_terragrunt_config("env.hcl", read_terragrunt_config(find_in_parent_folders("env.hcl", "does-not-exist.fallback"), { locals = {} }))
 
  # Extract the variables we need for easy access
  aws_region        = local.region_vars.locals.aws_region
  env               = local.env_vars.locals.env
}

# Overrides the default minimum supported version of terraform. Terragrunt only officially supports the latest version
# of terraform, however in some cases an old terraform is needed.
terraform_version_constraint = ">= 0.12.31"
# If the running version of Terragrunt doesn’t match the constraints specified, Terragrunt will produce an error and
# exit without taking any further actions.
terragrunt_version_constraint = ">= 0.26.7"

# Generate an AWS provider block
generate "provider" {
  path      = "provider.tf"
  if_exists = "skip"
  contents  = <<-EOF
    provider "aws" {
      region = "${local.aws_region}"
    }
  EOF
}

# Configure Terragrunt to automatically store tfstate files in an S3 bucket
remote_state {
  backend = "s3"

  config = {
    bucket         = "tfstate-${local.aws_region}-${local.env}-acme-corp"
    encrypt        = true
    key            = "${path_relative_to_include()}.tfstate"
    region         = "${local.aws_region}"
    dynamodb_table = "tfstate-${local.aws_region}-${local.env}"

  }

  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}

# Configure root level variables that all resources can inherit. This is especially helpful with multi-account configs
# where terraform_remote_state data sources are placed directly into the modules.
inputs = merge(
  local.region_vars.locals,
  local.env_vars.locals,
)
