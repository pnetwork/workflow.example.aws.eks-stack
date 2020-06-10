
####################################
# create eks iam role
#################################### 
resource "aws_iam_role" "eks_iam_role" {
  name = var.eks_iam_role

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

####################################
# attach policies to eks_iam_role 
####################################
resource "aws_iam_role_policy_attachment" "AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_iam_role.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.eks_iam_role.name
}

####################################
# create eks 
####################################
resource "aws_eks_cluster" "eks" {
  name = var.eks_cluster_name 

  # setup iam
  role_arn = aws_iam_role.eks_iam_role.arn

  # setup vpc
  vpc_config {
    # might cause zones that not available issue
    subnet_ids = var.subnet_ids
  }
  
  # Ensure that IAM Role permissions are created before and deleted after EKS Cluster handling.
  # Otherwise, EKS will not be able to properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.AmazonEKSServicePolicy,
  ]
}

output "output_eks" {
  value = aws_eks_cluster.eks
}
