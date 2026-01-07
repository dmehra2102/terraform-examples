output "key_arn" {
    value       = aws_kms_key.eks_secrets.arn
    description = "ARN of the KMS key for EKS secrets."
}
