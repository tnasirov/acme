include {
  path = find_in_parent_folders()
}

dependency "eks" {
  config_path = find_in_parent_folders("eks")
}

terraform {
  source = "git@github.com:tnasirov/terraform-modules.git//tf-aws-irsa?ref=main"
}


inputs = {
  serviceaccount_name     = "developer-test"
  pod_namespace           = "developer-test-ns"
  cluster_oidc_issuer_url = dependency.eks.outputs.cluster_oidc_issuer_url
  iam_policy_json         = templatefile("policy.json", {})
}
