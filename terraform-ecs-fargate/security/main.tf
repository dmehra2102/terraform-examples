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