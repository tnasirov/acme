
include {
  path = find_in_parent_folders()
}

dependency "vpc" {
  config_path = find_in_parent_folders("vpc")
}

terraform {
  source = "git@github.com:tnasirov/terraform-modules.git//tf-aws-eks?ref=main"
}

inputs = {
  cluster_version = "1.22"
  vpc_id          = dependency.vpc.outputs.vpc_id
  subnet_ids      = dependency.vpc.outputs.private_subnets
  
  node_groups = {
    ng1 = {
      instance_types = ["t3.small"]
      capacity_type  = "SPOT"
      min_size     = 1
      max_size     = 2
      desired_size = 1
    }
  }

  # map_roles = [
  #   {
  #     rolearn  = "arn:aws:iam::<account-id>:role/<role-name>"
  #     username = "<username>"
  #     groups   = ["system:masters"] # has to be trated carefully in real env
  #   },
  # ]

}