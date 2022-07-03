## Note
We assume that we have an account(in this case acme-non-prod), we have a programmatic access to the account. Terraform, Terragrunt and awscli installed.

This repo will deploy VPC, EKS cluster and IRSA role with an S3 access.
All the resources will be created in acme-non-prod account, us-east-1 region and for dev environment.
S3 backend and dynamoDB table for state lock also will be created 

## Usage

All the resources (VPC.EKS,IRSA) can be deployed via running command

``` terragrunt run-all apply ```

in folder "/acme/acme-non-prod/us-east-1/dev"

Whatever user/role deploys an EKS gets access to it.
So if it will be deployed by any CI role, in order any enduser/developer to have an access to EKS, we have to uncomment the commented out "map_roles" part in /acme/acme-non-prod/us-east-1/dev/eks/terragrunt.hcl and change it for our need e.g. add the role arn that we want to have an access to EKS cluster.

After deploying all the resources developer can run command below command to get access to EKS cluster

``` aws eks --region us-east-1 update-kubeconfig --name dev-eks ```

For creating a deployment/job that will have an access to S3 bucket, enduser/developer needs to 
 * Create a serviceaccount 
 * Annotate the serviceaccount with the arn of the irsa role(can be found in outputs) 
 * Create a deployment/job manifest
 * Add the serviceaccount to the manifest

Created resource will be able to assume the role and get access to S3 bucket.

### Important note!!!

Serviceaccount name and pod's namespace have to match with IRSA role's "serviceaccount_name" and "pod_namespace" parameters.
It can be edited in /acme/acme-non-prod/us-east-1/dev/irsa/developer-role/terragrunt.hcl and changed to whatever namespace and serviceaccount name you are going to use.