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
# get aws vpc subnet ids 
####################################
data "aws_subnet_ids" "subnet_ids" {
  vpc_id = var.vpc_id
}

####################################
# deploy alb-ingress-controller 
####################################
module "alb_ingress_controller" {
  source            = "./modules/alb_ingress_controller"
  eks_cluster_name  = var.eks_cluster_name
  # need to upgrade to 0.13 with feature module depends_on
}

####################################
# get aws security group 
####################################
data "aws_security_group" "security_group" {
  vpc_id = var.vpc_id
  filter {
    # use vpc default sg
    name = "group-name"
    values = ["${var.sg_name_prefix}*"]
  }
}

####################################
# deploy db (mysql) 
####################################
resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "test_db_subnet_group"
  subnet_ids = data.aws_subnet_ids.subnet_ids.ids 
}

resource "aws_db_instance" "aws_mysql" {
  allocated_storage      = var.db.mysql.storage_size
  storage_type           = "gp2"
  engine                 = var.db.mysql.type 
  engine_version         = var.db.mysql.version
  instance_class         = "db.t2.micro"
  name                   = var.db.mysql.db_name 
  username               = var.db.mysql.username 
  password               = var.db.mysql.password
  parameter_group_name   = var.db.mysql.parameter_group_name 
  port                   = var.db.mysql.port 
  db_subnet_group_name   = aws_db_subnet_group.db_subnet_group.id
  publicly_accessible    = var.db.mysql.is_public_access 
  skip_final_snapshot    = var.db.mysql.is_skip_final_snapshot 
  vpc_security_group_ids = [data.aws_security_group.security_group.id]
}

output "aws_mysql" {
  value = aws_db_instance.aws_mysql
}
