# ===============================
# Application Load Balancer
# ===============================
resource "aws_lb" "main" {
    name = "${var.project_name}-${var.environment}-alb"
    internal = false
    load_balancer_type = "application"
    security_groups = [var.alb_security_group_id]
    subnets = var.public_subnet_ids

    enable_deletion_protection = var.environment == "production" ? true: false
    enable_http2 = true
    enable_cross_zone_load_balancing = true
    idle_timeout = var.idle_timeout

    drop_invalid_header_fields = true

    access_logs {
        bucket  = aws_s3_bucket.alb_logs.bucket
        enabled = true
    }

    tags = merge(var.common_tags, {
        Name = "${var.project_name}-${var.environment}-alb"
    })
}

# ================================
# Target Group
# ================================
resource "aws_lb_target_group" "main" {
    name = "${var.project_name}-${var.environment}-tg"
    port = var.container_port
    protocol = "HTTP"
    vpc_id = var.vpc_id
    target_type = "ip"

    health_check {
        enabled = true
        healthy_threshold = var.health_check_healthy_threshold
        unhealthy_threshold = var.health_check_unhealthy_threshold
        timeout = var.health_check_timeout
        interval = var.health_check_interval
        path = var.health_check_path
        protocol = "HTTP"
        matcher = "200-299"
    }

    deregistration_delay = 30
    connection_termination = true

    stickiness {
        type = "lb_cookie"
        cookie_duration = 86400
        enabled = false
    }

    tags = merge(var.common_tags,{
        Name = "${var.project_name}-${var.environment}-tg"
    })

    lifecycle {
        create_before_destroy = true
    }
}

resource "aws_lb_listener" "https" {
    load_balancer_arn = aws_lb.main.arn
    port = "443"
    protocol = "HTTPS"
    ssl_policy = "ELBSecurityPolicy-TLS13-1-2-2021-06"
    certificate_arn = var.acm_certificate_arn

    default_action {
        type = "forward"
        target_group_arn = aws_lb_target_group.main.arn
    }

    tags = var.common_tags
}

# ============================================
# HTTP Listener (Redirect to HTTPS)
# ============================================
resource "aws_lb_listener" "http" {
    load_balancer_arn = aws_lb.main.arn
    port              = "80"
    protocol          = "HTTP"

    default_action {
        type = "redirect"

        redirect {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
        }
    }

    tags = var.common_tags
}

# =====================================
# ALB Access Logs (Best Practice)
# =====================================

resource "aws_s3_bucket" "alb_logs" {
    bucket = "${var.project_name}-${var.environment}-alb-logs-${data.aws_caller_identity.current.account_id}"

    tags = merge(var.common_tags, {
        Name = "${var.project_name}-${var.environment}-alb-logs"
    })
}

resource "aws_s3_bucket_lifecycle_configuration" "alb_logs" {
    bucket = aws_s3_bucket.alb_logs.id

    rule {
        id = "delete-old-logs"
        status = "Enabled"

        expiration {
            days = 90
        }
    }
}

resource "aws_s3_bucket_public_access_block" "alb_logs" {
    bucket = aws_s3_bucket.alb_logs.id

    block_public_acls       = true
    block_public_policy     = true
    ignore_public_acls      = true
    restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "alb_logs" {
    bucket = aws_s3_bucket.alb_logs.id

    rule {
        apply_server_side_encryption_by_default {
            sse_algorithm = "AES256"
        }
    }
}

# Get current AWS account ID
data "aws_caller_identity" "current" {}

# Get ELB service account for the region
data "aws_elb_service_account" "main" {}

resource "aws_s3_bucket_policy" "allow_access_from_another_account" {
    bucket = aws_s3_bucket.alb_logs.id
    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Effect = "Allow"
                Principal = {
                    AWS = data.aws_elb_service_account.main.arn
                }
                Action   = "s3:PutObject"
                Resource = "${aws_s3_bucket.alb_logs.arn}/*"
            },
            {
                Effect = "Allow"
                Principal = {
                    Service = "logdelivery.elasticloadbalancing.amazonaws.com"
                }
                Action   = "s3:PutObject"
                Resource = "${aws_s3_bucket.alb_logs.arn}/*"
                Condition = {
                    StringEquals = {
                        "aws:SourceAccount" = data.aws_caller_identity.current.account_id
                    }
                }
            }
        ]
    })
}