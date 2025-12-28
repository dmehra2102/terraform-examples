resource "aws_iam_policy" "ebs_csi_iam_policy" {
    name = "ebs-csi-iam-policy"
    path = "/"

    policy = data.http.ebs_csi_iam_policy.response_body
}


resource "aws_iam_role" "ebs_csi_iam_role" {
    name = "ebs-csi-iam-role"

    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Action = "sts:AssumeRoleWithWebIdentity"
                Effect = "Allow"
                Sid    = "EBSCSIAllow"
                Principal = {
                    Federated : "${data.terraform_remote_state.eks_cluster_remote_state.outputs.aws_iam_openid_connect_provider_arn}"
                }
                Condition = {
                    StringEquals : {
                        "${data.terraform_remote_state.eks_cluster_remote_state.outputs.aws_iam_openid_connect_provider_extract_from_arn}:sub" : "system:serviceaccount:kube-system:ebs-csi-controller-sa"
                    }
                }
            },
        ]
    })
}

resource "aws_iam_role_policy_attachment" "ebs_csi_iam_role_policy_attachment" {
    role = aws_iam_role.ebs_csi_iam_role.name
    policy_arn = aws_iam_policy.ebs_csi_iam_policy.arn
}