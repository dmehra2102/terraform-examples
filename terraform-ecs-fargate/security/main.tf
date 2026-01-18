# =============================
# ALB Security Group
# =============================
resource "aws_security_group" "alb" {
    name = "${var.project_name}-${var.environment}-alb-sg"
    description = "Security group for Application Load Balancer"
    vpc_id = var.vpc_id

    tags = merge(var.common_tags, {
        Name = "${var.project_name}-${var.environment}-alg-sg"
    })
}

# Allow HTTP traffic from anywhere
resource "aws_vpc_security_group_ingress_rule" "alb_http" {
    security_group_id = aws_security_group.alb.id
    description = "Allow HTTP traffic from internet"

    from_port = 80
    to_port = 80
    ip_protocol = "tcp"
    cidr_ipv4 = "0.0.0.0/0"

    tags = {
        Name = "allow-http-ingress"
    }
}

# Allow HTTPS traffic from anywhere
resource "aws_vpc_security_group_ingress_rule" "alb_https" {
    security_group_id = aws_security_group.alb.id
    description = "Allow HTTPS traffic from internet"

    from_port = 443
    to_port = 443
    ip_protocol = "tcp"
    cidr_ipv4 = "0.0.0.0/0"

    tags = {
        Name = "allow-https-ingress"
    }
}

# Allow all outbound traffic
resource "aws_vpc_security_group_egress_rule" "alb_egress" {
    security_group_id = aws_security_group.alb.id
    description = "Allow all outbound traffic"

    ip_protocol = "-1"
    cidr_ipv4 = "0.0.0.0/0"

    tags = {
        Name = "allow-all-egress"
    }
}

# ================================
# ECS Task Security Group
# ================================
resource "aws_security_group" "ecs_task" {
    name = "${var.project_name}-${var.environment}-ecs-task-sg"
    description = "Security group for ECS tasks - allows traffic only from ALB"
    vpc_id = var.vpc_id

    tags = {
        Name = "${var.project_name}-${var.environment}-ecs-task-sg"
    }
}

# Allow traffic from ALB only on container port
resource "aws_vpc_security_group_ingress_rule" "ecs_task_from_alb" {
    security_group_id = aws_security_group.ecs_task.id
    description = "Allow taffic from ALB on container port"

    from_port = var.container_port
    to_port = var.container_port
    ip_protocol = "tcp"
    referenced_security_group_id = aws_security_group.alb.id

    tags = {
        Name = "allow-alb-ingress"
    }
}

# Allow all outbound traffic (for pulling images, accessing AWS services, external APIs)
resource "aws_vpc_security_group_egress_rule" "ecs_task_egress" {
    security_group_id = aws_security_group.ecs_task.id
    description = "Allow all outbound traffic"

    ip_protocol = "-1"
    cidr_ipv4 = "0.0.0.0/0"

    tags = {
        Name = "allow-all-egress"
    }
}

# ==================================
# IAM Role for ECS Task Execution
# ==================================
resource "aws_iam_role" "ecs_task_execution" {
    name = "${var.project_name}-${var.environment}-ecs-task-execution-role"

    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Action = "sts:AssumeRole"
                Effect = "Allow"
                Principal = {
                    Service = "ecs-tasks.amazonaws.com"
                }
            }
        ]
    })

    tags = var.common_tags
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_policy" {
    role = aws_iam_role.ecs_task_execution.name
    policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Additional policy for Secrets Manager and SSM Parameter Store access
resource "aws_iam_role_policy" "ecs_task_execution_secrets" {
    name = "${var.project_name}-${var.environment}-ecs-task-execution-secrets-policy"
    role = aws_iam_role.ecs_task_execution.id

    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Effect = "Allow"
                Action = [
                    "secretsmanager:GetSecretValue",
                    "kms:Decrypt"
                ]
                Resource = [
                    "arn:aws:secretsmanager:*:*:secret:${var.project_name}/${var.environment}/*",
                    "arn:aws:kms:*:*:key/*"
                ]
            },
            {
                Effect = "Allow"
                Action = [
                    "ssm:GetParameters",
                    "ssm:GetParameter",
                    "ssm:GetParametersByPath"
                ]
                Resource = [
                    "arn:aws:ssm:*:*:parameter/${var.project_name}/${var.environment}/*"
                ]
            }
        ]
    })
}

# ============================================
# IAM Role for ECS Task (Application Runtime)
# ============================================
resource "aws_iam_role" "ecs_task" {
    name = "${var.project_name}-${var.environment}-ecs-task-role"

    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
        {
            Action = "sts:AssumeRole"
            Effect = "Allow"
            Principal = {
                Service = "ecs-tasks.amazonaws.com"
            }
        }
        ]
    })

    tags = var.common_tags
}

# Policy for application runtime permissions
resource "aws_iam_role_policy" "ecs_task_policy" {
    name = "${var.project_name}-${var.environment}-ecs-task-policy"
    role = aws_iam_role.ecs_task.id

    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Effect = "Allow"
                Action = [
                    "ssm:GetParameter",
                    "ssm:GetParameters",
                    "ssm:GetParametersByPath"
                ]
                Resource = [
                    "arn:aws:ssm:*:*:parameter/${var.project_name}/${var.environment}/*"
                ]
            },
            {
                Effect = "Allow"
                Action = [
                    "secretsmanager:GetSecretValue"
                ]
                Resource = [
                    "arn:aws:secretsmanager:*:*:secret:${var.project_name}/${var.environment}/*"
                ]
            },
            {
                Effect = "Allow"
                Action = [
                    "s3:GetObject",
                    "s3:PutObject",
                    "s3:ListBucket"
                ]
                Resource = [
                    "arn:aws:s3:::${var.project_name}-${var.environment}-*",
                    "arn:aws:s3:::${var.project_name}-${var.environment}-*/*"
                ]
            },
            {
                Effect = "Allow"
                Action = [
                    "kms:Decrypt",
                    "kms:GenerateDataKey"
                ]
                Resource = [
                    "arn:aws:kms:*:*:key/*"
                ]
                Condition = {
                    StringEquals = {
                        "kms:ViaService" = [
                            "s3.*.amazonaws.com",
                            "secretsmanager.*.amazonaws.com",
                            "ssm.*.amazonaws.com"
                        ]
                    }
                }
            }
        ]
    })
}

# Policy for ECS Exec (if enabled)
resource "aws_iam_role_policy" "ecs_exec_policy" {
    name = "${var.project_name}-${var.environment}-ecs-exec-policy"
    role = aws_iam_role.ecs_task.id

    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Effect = "Allow"
                Action = [
                    "ssmmessages:CreateControlChannel",
                    "ssmmessages:CreateDataChannel",
                    "ssmmessages:OpenControlChannel",
                    "ssmmessages:OpenDataChannel"
                ]
                Resource = "*"
            },
            {
                Effect = "Allow"
                Action = [
                    "logs:DescribeLogGroups",
                    "logs:CreateLogStream",
                    "logs:DescribeLogStreams",
                    "logs:PutLogEvents"
                ]
                Resource = "*"
            }
        ]
    })
}