####################################
# get current aws region
#################################### 
data "aws_region" "current" {}

###################################
# fetch OIDC provider thumbprint for root CA
################################### 
data "external" "thumbprint" {
  program = ["./modules/iam_openid_connect_provider/oidc-thumbprint.sh", data.aws_region.current.name]
}

###################################
# configure thumbprint for root CA
################################### 
resource "aws_iam_openid_connect_provider" "iam_openid_connect_provider" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = concat([data.external.thumbprint.result.thumbprint], var.oidc_thumbprint_list)
  url             = var.cluster_issuer 
}

###################################
# attach iam role to open_id connect provider 
###################################
data "aws_iam_policy_document" "iam_policy_document" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.iam_openid_connect_provider.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:aws-node"]
    }

    principals {
      identifiers = [aws_iam_openid_connect_provider.iam_openid_connect_provider.arn]
      type        = "Federated"
    }
  }
}

resource "aws_iam_role" "assume_role_policy" {
  assume_role_policy = data.aws_iam_policy_document.iam_policy_document.json
  name               = "assume_role_policy"
}

output "output_iam_openid_connect_provider" {
  value = aws_iam_openid_connect_provider.iam_openid_connect_provider 
}
