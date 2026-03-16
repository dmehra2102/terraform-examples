output "eks_kms_key_arn"                { value = aws_kms_key.eks.arn }
output "msk_kms_key_arn"                { value = aws_kms_key.msk.arn }
output "secrets_kms_key_arn"            { value = aws_kms_key.secrets.arn }
output "pod_read_secrets_policy_arn"    { value = aws_iam_policy.read_secrets.arn }
output "eso_controller_policy_arn"      { value = aws_iam_policy.external_secrets_operator.arn }
output "kafka_bootstrap_secret_arn"     { value = aws_secretsmanager_secret.kafka_bootstrap.arn }
output "schema_registry_secret_arn"     { value = aws_secretsmanager_secret.kafka_schema_registry.arn }
