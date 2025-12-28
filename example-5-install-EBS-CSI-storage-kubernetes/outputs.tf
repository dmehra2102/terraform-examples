output "ebs_iam_policy_arn" {
    value = aws_iam_policy.ebs_csi_iam_policy.arn
}

output "ebs_csi_helm_metadata" {
    description = "Metadata Block outlining status of the deployed release."
    value = helm_release.ebs_csi_driver.metadata
}