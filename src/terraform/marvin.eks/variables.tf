variable "region" {
  default = ""
}

variable "access_key" {
  default = ""
}

variable "secret_key" {
  default = ""
}

variable "vpc_id" {
  default = ""
}

variable "eks_cluster_name" {
}

variable "eks_iam_role" {
  default = "eks_iam_role"
}

variable "eks_node_group_iam_role" {
  default = "eks_node_group_iam_role"
}

variable "eks_node_group_name" {}

