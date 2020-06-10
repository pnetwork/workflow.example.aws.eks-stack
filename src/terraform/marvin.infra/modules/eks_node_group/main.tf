####################################
# create eks node group iam role 
####################################
resource "aws_iam_role" "eks_node_group" {
  name = var.iam_role 

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

####################################
# attach policies to aws_iam_role.eks_node_group 
####################################
resource "aws_iam_role_policy_attachment" "AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_node_group.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_node_group.name
}

resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_node_group.name
}

####################################
# create eks node group 
####################################
resource "aws_eks_node_group" "eks_node_group" {
  # required arguments
  cluster_name    = var.cluster_name 
  node_group_name = var.name 
  node_role_arn   = aws_iam_role.eks_node_group.arn
  subnet_ids      = toset(var.subnet_ids)
  dynamic scaling_config {
    for_each = [var.scaling_config]
    content {
      desired_size = var.scaling_config.desired_size
      max_size     = var.scaling_config.max_size
      min_size     = var.scaling_config.min_size
    }
  }
  
  # optional arguments
  ami_type             = var.ami_type
  disk_size            = var.disk_size
  # force_update_version = var.force_update_version
  instance_types       = var.instance_types
  labels               = var.labels
  tags                 = var.tags
  dynamic remote_access {
    for_each = [var.remote_access]
    content {
      ec2_ssh_key               = var.remote_access.ec2_ssh_key
      source_security_group_ids = var.remote_access.source_security_group_ids
    }
  }
  
  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
  ]
}

output "output_eks_node_group" {
  value = aws_eks_node_group.eks_node_group
}
