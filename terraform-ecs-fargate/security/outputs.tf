output "alb_security_group_id" {
    description = "ID of ALB security group"
    value       = aws_security_group.alb.id
}

output "ecs_task_security_group_id" {
    description = "ID of ECS task security group"
    value       = aws_security_group.ecs_task.id
}

output "ecs_task_execution_role_arn" {
    description = "ARN of ECS task execution role"
    value       = aws_iam_role.ecs_task_execution.arn
}

output "ecs_task_role_arn" {
    description = "ARN of ECS task role"
    value       = aws_iam_role.ecs_task.arn
}