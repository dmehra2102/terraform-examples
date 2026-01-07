resource "aws_kms_key" "eks_secrets" {
    description = "KMS key for EKS sercrets encryption"
    deletion_window_in_days = 30
    enable_key_rotation = true

    policy = var.kms_key_policy_json != "" ? var.kms_key_policy_json : null

    tags = merge(var.tags, {
        Name = "${var.name_prefix}-eks-secrets-kms"
    })
}

resource "aws_kms_alias" "eks_secrets" {
    name = "alias/${var.name_prefix}-eks-secrets"
    target_key_id = aws_kms_key.eks_secrets.id
}