# =============================================================================
# KMS KEY: EKS Secrets Encryption (envelope encryption for k8s secrets)
# =============================================================================

resource "aws_kms_key" "eks" {
    description = "${var.name_prefix} EKS secrets envelope encryption"
    deletion_window_in_days = 30
    enable_key_rotation = true
    multi_region = false

    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Sid = "Enable IAM root full access"
                Effect = "Allow"
                Principal = {
                    AWS = "arn:aws:iam::${var.account_id}:root"
                }
                Action = "kms:*"
                Resource = "*"
            },
            {
                Sid    = "Allow EKS service to use key"
                Effect = "Allow"
                Principal = { Service = "eks.amazonaws.com" }
                Action = [
                    "kms:Encrypt", 
                    "kms:Decrypt", 
                    "kms:ReEncrypt*",
                    "kms:GenerateDataKey*", 
                    "kms:DescribeKey"
                ]
                Resource = "*"
            }
        ]
    })

    tags = { 
        Name = "${var.name_prefix}-kms-eks"
        Purpose = "EKSSecretsEncryption" 
    }
}

resource "aws_kms_alias" "eks" {
    name          = "alias/${var.name_prefix}-eks"
    target_key_id = aws_kms_key.eks.key_id
}

# =============================================================================
# KMS KEY: MSK / Kafka at-rest encryption
# =============================================================================
resource "aws_kms_key" "msk" {
    description = "${var.name_prefix} MSK broker storage encryption"
    deletion_window_in_days = 30
    enable_key_rotation = true

    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Sid = "Enable IAM root full access"
                Effect = "Allow"
                Principal = {
                    AWS = "arn:aws:iam::${var.account_id}:root"
                }
                Action = "kms:*"
                Resource = "*"
            },
            {
                Sid = "Allow MSK service to use key"
                Effect = "Allow"
                Principal = {
                    Service = "kafka.amazonaws.com"
                }
                Action = [
                    "kms:Encrypt",
                    "kms:Decrypt",
                    "kms:ReEncrypt*",
                    "kms:GenerateDataKey*", 
                    "kms:DescribeKey",
                    "kms:CreateGrant"
                ]
                Resource = "*"
            }
        ]
    })

    tags = { 
        Name = "${var.name_prefix}-kms-msk" 
        Purpose = "MSKStorageEncryption" 
    }
}

resource "aws_kms_alias" "msk" {
    name          = "alias/${var.name_prefix}-msk"
    target_key_id = aws_kms_key.msk.key_id
}

# =============================================================================
# KMS KEY: Application secrets in Secrets Manager
# =============================================================================

resource "aws_kms_key" "secrets" {
    description             = "${var.name_prefix} AWS Secrets Manager encryption"
    deletion_window_in_days = 30
    enable_key_rotation     = true

    tags = { 
        Name = "${var.name_prefix}-kms-secrets"
        Purpose = "SecretsManagerEncryption"
    }
}

resource "aws_kms_alias" "secrets" {
    name          = "alias/${var.name_prefix}-secrets"
    target_key_id = aws_kms_key.secrets.key_id
}

# =============================================================================
# SECRETS MANAGER: Kafka bootstrap brokers secret
# (MSK module will write the actual value via aws_secretsmanager_secret_version)
# =============================================================================

resource "aws_secretsmanager_secret" "kafka_bootstrap" {
    name                    = "/${var.name_prefix}/kafka/bootstrap-brokers"
    description             = "MSK TLS bootstrap broker string"
    kms_key_id              = aws_kms_key.secrets.key_id
    recovery_window_in_days = 30
    tags                    = { Name = "${var.name_prefix}-secret-kafka-bootstrap" }
}

resource "aws_secretsmanager_secret" "kafka_schema_registry" {
    name                    = "/${var.name_prefix}/kafka/schema-registry-url"
    description             = "Confluent Schema Registry internal URL"
    kms_key_id              = aws_kms_key.secrets.key_id
    recovery_window_in_days = 30
    tags                    = { Name = "${var.name_prefix}-secret-schema-registry" }
}

# =============================================================================
# IAM POLICY: Allow pods to read Secrets Manager (attached via IRSA)
# =============================================================================
resource "aws_iam_policy" "read_secrets" {
    name = "${var.name_prefix}-pod-read-secrets"
    description = "Allow pods to read secrets from Secrets Manager via IRSA"

    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Sid = "ReadSecretsManager"
                Effect = "Allow"
                Action = [
                    "secretsmanager:GetSecretValue",
                    "secretsmanager:DescribeSecret",
                    "secretsmanager:ListSecretVersionIds"
                ]
                Resource = "arn:aws:secretsmanager:${var.aws_region}:${var.account_id}:secret:/${var.name_prefix}/*"
            },
            {
                Sid    = "DecryptWithKMS"
                Effect = "Allow"
                Action = ["kms:Decrypt", "kms:DescribeKey", "kms:GenerateDataKey"]
                Resource = aws_kms_key.secrets.arn
            }
        ]
    })
}

# =============================================================================
# IAM POLICY: External Secrets Operator controller
# =============================================================================

resource "aws_iam_policy" "external_secrets_operator" {
    name        = "${var.name_prefix}-eso-controller"
    description = "Permissions for the External Secrets Operator to sync secrets"

    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
        {
            Sid    = "SecretsManagerAccess"
            Effect = "Allow"
            Action = [
                "secretsmanager:GetSecretValue",
                "secretsmanager:DescribeSecret",
                "secretsmanager:ListSecrets",
                "secretsmanager:ListSecretVersionIds"
            ]
            Resource = "*"
        },
        {
            Sid    = "KMSDecrypt"
            Effect = "Allow"
            Action = ["kms:Decrypt", "kms:DescribeKey"]
            Resource = [aws_kms_key.secrets.arn, aws_kms_key.msk.arn]
        }
        ]
    })
}