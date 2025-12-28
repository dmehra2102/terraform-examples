resource "aws_iam_policy" "ebs_csi_driver_policy" {
    name = "ebs-csi-driver-policy"
    path = "/"
    policy = data.http.ebs_csi_policy_data.response_body
}

resource "aws_iam_role" "ebs_csi_driver_role" {
    name = "ebs-csi-driver-role"
    assume_role_policy = jsonencode({
        Version : "2012-10-17"
        Statement : [
            {
                Action: "sts:AssumeRoleWithWebIdentity"
                Effect : "Allow"
                Sid    = "EBSCSIAllow"
                Principal = {
                    Federated = "${local.aws_iam_oidc_provider_arn}"
                }
                Condition = {
                    StringEquals : {
                        "${local.aws_iam_oidc_connect_provider_extract_from_arn}:sub" : "system:serviceaccount:kube-system:ebs-csi-controller-sa"
                    }
                }
            }
        ]
    })
}

resource "aws_iam_role_policy_attachment" "ebs_csi_role_policy_attachment" {
    policy_arn = aws_iam_policy.ebs_csi_driver_policy.arn
    role = aws_iam_role.ebs_csi_driver_role.name
}