variable "subnet_ids" {
}

variable "cluster_name" {
}

variable "iam_role" {
}

variable "name" {
}

variable "scaling_config" {
  type = object({
    desired_size = number
    max_size = number
    min_size = number
  })
  default = {
    desired_size = 1
    max_size = 1
    min_size = 1
  }
}

variable "ami_type" {
  type = string
  default = "AL2_x86_64"
}

variable "disk_size" {
  type = number
  default = 20
}

variable "force_update_version" {
  type = bool
  default = true 
}

variable "instance_types" {
  type = list(string)
  default = ["t3.medium"]
}

variable "labels" {
  type = map 
  default = {}
}

variable "remote_access" {
  type = object({
    ec2_ssh_key = string
    source_security_group_ids = list(string)
  })
  default = {
    ec2_ssh_key = ""
    source_security_group_ids = [] 
  }
}

variable "tags" {
  type = map
  default = {}
}
