terraform {
  required_version = ">= 0.12, < 0.13"
}

####################################
# configure aws provider 
####################################
provider "aws" {
  region  = var.region 
  access_key = var.access_key 
  secret_key = var.secret_key 
  # Allow any 2.x version of the AWS provider
  version = "~> 2.0"
}

####################################
# get aws vpc 
####################################
data "aws_vpc" "vpc" {
  id = var.vpc_id 
}

####################################
# get aws vpc subnet ids 
####################################
data "aws_subnet_ids" "subnet_ids" {
  vpc_id = data.aws_vpc.vpc.id
}

####################################
# create aws eks 
####################################
module "eks" {
  source           = "./modules/eks"
  eks_iam_role     = var.eks_iam_role
  eks_cluster_name = var.eks_cluster_name
  subnet_ids       = data.aws_subnet_ids.subnet_ids.ids
}

output "eks_output" {
  value = module.eks.output_eks
}

####################################
# create aws eks node group 
####################################
module "eks_node_group" {
  source       = "./modules/eks_node_group"
  cluster_name = var.eks_cluster_name
  name         = var.eks_node_group_name
  subnet_ids   = data.aws_subnet_ids.subnet_ids.ids
  iam_role     = var.eks_node_group_iam_role 

}

output "eks_node_group_output" {
  value = module.eks_node_group.output_eks_node_group
}

