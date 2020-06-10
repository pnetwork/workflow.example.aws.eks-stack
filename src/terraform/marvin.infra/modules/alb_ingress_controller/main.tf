locals {
  # Your AWS EKS Cluster ID goes here.
  k8s_cluster_name = var.eks_cluster_name 
}

data "aws_region" "current" {}

data "aws_eks_cluster" "target" {
  name = local.k8s_cluster_name 
}

data "aws_eks_cluster_auth" "aws_iam_authenticator" {
  name = data.aws_eks_cluster.target.name
}


####################################
# setup kubernetes provider 
####################################
provider "kubernetes" {
  alias = "eks"
  host                   = data.aws_eks_cluster.target.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.target.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.aws_iam_authenticator.token
  load_config_file       = false
}


####################################
# create alb-ingress-controller 
####################################
module "alb_ingress_controller" {
  source  = "iplabs/alb-ingress-controller/kubernetes"
  version = "3.1.0"

  providers = {
    kubernetes = kubernetes.eks
  }

  k8s_cluster_type = "eks"
  k8s_namespace    = "kube-system"

  aws_region_name  = data.aws_region.current.name
  k8s_cluster_name = data.aws_eks_cluster.target.name
}
