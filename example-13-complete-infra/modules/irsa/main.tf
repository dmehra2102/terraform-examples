data "aws_iam_policy_document" "sa_assume" {
    statement {
        actions = [ "sts:AssumeRoleWithWebIdentity" ]
        principals {
            type = "Federated"
            identifiers = [ var.oidc_provider_arn ]
        }
        condition {
            test = "StringEquals"
            variable = "${var.oidc_provider_url}:sub"
            values = [ "system:serviceaccount:${var.namespace}:${var.service_account_name}" ]
        }
    }
}

resource "aws_iam_role" "this" {
    name               = "${var.name_prefix}-${var.service_account_name}-irsa"
    assume_role_policy = data.aws_iam_policy_document.sa_assume.json

    tags = merge(var.tags, { 
        Name = "${var.name_prefix}-${var.service_account_name}-irsa" 
    })
}

resource "aws_iam_policy" "custom" {
    count       = var.inline_policy_json != "" ? 1 : 0
    name        = "${var.name_prefix}-${var.service_account_name}-policy"
    description = "Custom inline policy for IRSA role"
    policy      = var.inline_policy_json

    tags = var.tags
}

resource "aws_iam_role_policy_attachment" "attach_custom" {
    count      = var.inline_policy_json != "" ? 1 : 0
    role       = aws_iam_role.this.name
    policy_arn = aws_iam_policy.custom[0].arn
}