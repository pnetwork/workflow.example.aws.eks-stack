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

variable "sg_name_prefix" {
}

variable "db" {
  type = object({
    mysql = object({
      type                   = string
      version                = string
      db_name                = string
      username               = string
      password               = string
      parameter_group_name   = string
      storage_type           = string
      storage_size           = number
      port                   = number
      is_public_access       = bool
      is_skip_final_snapshot = bool
    })
  })
  default = {
    mysql = {
      type                   = "mysql" 
      version                = "5.7" 
      db_name                = "test-db-name" 
      username               = "" 
      password               = "" 
      parameter_group_name   = "default.mysql5.7" 
      storage_type           = "gp2" 
      storage_size           = 20 
      port                   = 3306 
      is_public_access       = true 
      is_skip_final_snapshot = true 
    }
  }
}


