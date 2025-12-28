resource "aws_eks_addon" "ebs_csi_driver" {
    cluster_name = aws_eks_cluster.my_eks_cluster.name
    addon_name = "aws-ebs-csi-driver"
    service_account_role_arn = aws_iam_role.ebs_csi_driver_role.arn

    depends_on = [ 
        aws_iam_role_policy_attachment.ebs_csi_role_policy_attachment
    ]
}