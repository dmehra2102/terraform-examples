# ============================
# CloudWatch Log Group
# ============================
resource "aws_cloudwatch_log_group" "ecs" {
    name = "/ecs/${var.project_name}-${var.environment}"
    retention_in_days = var.log_retention_days

    tags = merge(var.common_tags,{
        Name = "${var.project_name}-${var.environment}-log-group"
    })
}

# ================================
# ECS Cluster
# ================================
resource "aws_ecs_cluster" "main" {
    name = "${var.project_name}-${var.environment}-cluster"

    setting {
        name = "containerInsights"
        value = "enabled"
    }

    tags = merge(var.common_tags, {
        Name = "${var.project_name}-${var.environment}-cluster"
    })
}

# =================================
# ECS Cluster Capacity Providers
# =================================
resource "aws_ecs_cluster_capacity_providers" "main" {
    cluster_name = aws_ecs_cluster.main.name
    capacity_providers = ["FARGATE"]

    default_capacity_provider_strategy {
        capacity_provider = "FARGATE"
        weight            = 1
        base              = 1
    }
}

# ==================================
# ECS Task Definition
# ==================================
resource "aws_ecs_task_definition" "main" {
    family = "${var.project_name}-${var.environment}"
    network_mode             = "awsvpc"
    requires_compatibilities = ["FARGATE"]
    cpu                      = var.task_cpu
    memory                   = var.task_memory
    execution_role_arn       = data.aws_iam_role.ecs_task_execution.arn
    task_role_arn            = data.aws_iam_role.ecs_task.arn

    container_definitions    = jsonencode([
        {
            name = var.container_name
            image = "${var.ecr_repository_url}:latest"
            essential = true

            portMappings = [
                {
                    containerPort = var.container_port
                    hostPort = var.container_port
                    protocol = "tcp"
                }
            ]

            environment = [
                {
                    name  = "ENVIRONMENT"
                    value = var.environment
                },
                {
                    name  = "PORT"
                    value = tostring(var.container_port)
                },
                {
                    name  = "AWS_REGION"
                    value = var.aws_region
                }
            ]

            # Health check configuration
            healthCheck = {
                command     = ["CMD-SHELL", "wget --no-verbose --tries=1 --spider http://localhost:${var.container_port}/health || exit 1"]
                interval    = 30
                timeout     = 5
                retries     = 3
                startPeriod = 60
            }

            # Logging configuration
            logConfiguration = {
                logDriver = "awslogs"
                options = {
                "awslogs-group"         = aws_cloudwatch_log_group.ecs.name
                "awslogs-region"        = var.aws_region
                "awslogs-stream-prefix" = "ecs"
                }
            }

            # Linux parameters for better performance
            linuxParameters = {
                initProcessEnabled = true
            }

            # Stop timeout
            stopTimeout = 30
        }
    ])

    # Runtime platform
    runtime_platform {
        operating_system_family = "LINUX"
        cpu_architecture        = "X86_64"
    }

    tags = merge(var.common_tags,{
            Name = "${var.project_name}-${var.environment}-task-definition"
        }
    )
}

data "aws_iam_role" "ecs_task_execution" {
    name = "${var.project_name}-${var.environment}-ecs-task-execution-role"
}

data "aws_iam_role" "ecs_task" {
    name = "${var.project_name}-${var.environment}-ecs-task-role"
}

# ============================
# ECS Service
# ============================
resource "aws_ecs_service" "main" {
    name = "${var.project_name}-${var.environment}-service"
    cluster = aws_ecs_cluster.main.id
    task_definition = aws_ecs_task_definition.main.arn
    desired_count = var.desired_count
    launch_type = "FARGATE"
    platform_version = "LATEST"

    deployment_maximum_percent = 200
    deployment_minimum_healthy_percent = 100

    deployment_circuit_breaker {
        enable = true
        rollback = true
    }

    network_configuration {
        assign_public_ip = false
        subnets = var.private_subnet_ids
        security_groups = [ var.ecs_task_security_group_id ]
    }

    load_balancer {
        target_group_arn = var.target_group_arn
        container_name   = var.container_name
        container_port   = var.container_port
    }

    # Health check grace period
    health_check_grace_period_seconds = 60

    # Enable ECS Exec for debugging
    enable_execute_command = var.enable_execute_command

    propagate_tags = "TASK_DEFINITION"

    tags = merge(var.common_tags,{
        Name = "${var.project_name}-${var.environment}-service"
    })

    # Ensure service is created after target group
    depends_on = [var.target_group_arn]

    lifecycle {
        ignore_changes = [desired_count]
    }
}

# ============================================
# Auto Scaling Target
# ============================================
resource "aws_appautoscaling_target" "ecs" {
    max_capacity = var.max_capacity
    min_capacity = var.min_capacity
    service_namespace = "ecs"
    resource_id = "service/${aws_ecs_cluster.main.name}/${aws_ecs_service.main.name}"
    scalable_dimension = "ecs:service:DesiredCount"
}

# ============================================
# Auto Scaling Policy - CPU
# ============================================
resource "aws_appautoscaling_policy" "ecs_cpu" {
    name               = "${var.project_name}-${var.environment}-cpu-scaling"
    policy_type        = "TargetTrackingScaling"
    resource_id = aws_appautoscaling_target.ecs.resource_id
    scalable_dimension = aws_appautoscaling_target.ecs.scalable_dimension
    service_namespace = aws_appautoscaling_target.ecs.service_namespace

    target_tracking_scaling_policy_configuration {
        target_value = var.cpu_target_value
        scale_in_cooldown = var.scale_in_cooldown
        scale_out_cooldown = var.scale_out_cooldown

        predefined_metric_specification {
            predefined_metric_type = "ECSServiceAverageCPUUtilization"
        }
    }
}

# ============================================
# Auto Scaling Policy - Memory
# ============================================
resource "aws_appautoscaling_policy" "ecs_memory" {
    name               = "${var.project_name}-${var.environment}-memory-scaling"
    policy_type        = "TargetTrackingScaling"
    resource_id        = aws_appautoscaling_target.ecs.resource_id
    scalable_dimension = aws_appautoscaling_target.ecs.scalable_dimension
    service_namespace  = aws_appautoscaling_target.ecs.service_namespace

    target_tracking_scaling_policy_configuration {
        target_value       = var.memory_target_value
        scale_in_cooldown  = var.scale_in_cooldown
        scale_out_cooldown = var.scale_out_cooldown

        predefined_metric_specification {
            predefined_metric_type = "ECSServiceAverageMemoryUtilization"
        }
    }
}

# ============================================
# CloudWatch Alarms
# ============================================
resource "aws_cloudwatch_metric_alarm" "ecs_cpu_high" {
    alarm_name          = "${var.project_name}-${var.environment}-cpu-utilization-high"
    comparison_operator = "GreaterThanThreshold"
    evaluation_periods  = "2"
    metric_name         = "CPUUtilization"
    namespace           = "AWS/ECS"
    period              = "60"
    statistic           = "Average"
    threshold           = "85"
    alarm_description   = "This metric monitors ECS CPU utilization"
    treat_missing_data  = "notBreaching"

    dimensions = {
        ClusterName = aws_ecs_cluster.main.name
        ServiceName = aws_ecs_service.main.name
    }

    tags = var.common_tags
}

resource "aws_cloudwatch_metric_alarm" "ecs_memory_high" {
    alarm_name          = "${var.project_name}-${var.environment}-memory-utilization-high"
    comparison_operator = "GreaterThanThreshold"
    evaluation_periods  = "2"
    metric_name         = "MemoryUtilization"
    namespace           = "AWS/ECS"
    period              = "60"
    statistic           = "Average"
    threshold           = "85"
    alarm_description   = "This metric monitors ECS memory utilization"
    treat_missing_data  = "notBreaching"

    dimensions = {
        ClusterName = aws_ecs_cluster.main.name
        ServiceName = aws_ecs_service.main.name
    }

    tags = var.common_tags
}