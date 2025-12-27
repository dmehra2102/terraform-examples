resource "aws_iam_role" "irsa_iam_role" {
    name = "irsa-iam-role"

    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Action = "sts:AssumeRoleWithWebIdentity"
                Effect = "Allow"
                Sid    = "IRSAIAMRole"
                Principal = {
                    Federated = "${data.terraform_remote_state.eks_cluster.outputs.aws_iam_openid_connect_provider_arn}"
                }
                Condition : {
                    StringEquals : {
                        "${data.terraform_remote_state.eks_cluster.outputs.aws_iam_openid_connect_provider_extract_from_arn}:sub" : "system:serviceaccount:default:irsa-demo-sa"
                    }
                }
            },
        ]
    })
}

resource "aws_iam_role_policy_attachment" "irsa_iam_role_policy_attach" {
    policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
    role       = aws_iam_role.irsa_iam_role.name
}

output "irsa_iam_role_arn" {
    description = "IRSA Demo IAM Role ARN"
    value = aws_iam_role.irsa_iam_role.arn
}