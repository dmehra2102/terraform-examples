# ============================================
# General Configuration
# ============================================
aws_region   = "ap-south-1"
environment  = "production"
project_name = "golang-app"

common_tags = {
    Project     = "golang-app"
    Environment = "production"
    ManagedBy   = "Terraform"
    Owner       = "DevOps Team"
    CostCenter  = "Engineering"
}

# ============================================
# Networking Configuration
# ============================================
vpc_cidr             = "10.0.0.0/16"
availability_zones   = ["ap-south-1a", "ap-south-1b"]
public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnet_cidrs = ["10.0.11.0/24", "10.0.12.0/24"]

# ============================================
# ALB Configuration
# ============================================
# Replace with your ACM certificate ARN
acm_certificate_arn              = "arn:aws:acm:us-east-1:123456789012:certificate/12345678-1234-1234-1234-123456789012"
alb_idle_timeout                 = 60
health_check_path                = "/health"
health_check_interval            = 30
health_check_timeout             = 5
health_check_healthy_threshold   = 2
health_check_unhealthy_threshold = 3

# ============================================
# ECS Configuration
# ============================================
container_name = "golang-app"
container_port = 8080
task_cpu       = 512  # 0.5 vCPU
task_memory    = 1024 # 1 GB

# Service configuration
desired_count = 2
min_capacity  = 1
max_capacity  = 5

# Auto Scaling configuration
cpu_target_value    = 70
memory_target_value = 80
scale_in_cooldown   = 300 # 5 minutes
scale_out_cooldown  = 60  # 1 minute

# ============================================
# CloudWatch Configuration
# ============================================
log_retention_days = 15

# ============================================
# ECR Configuration
# ============================================
ecr_image_tag_mutability           = "MUTABLE"
ecr_untagged_image_expiration_days = 7

# ============================================
# Application Configuration
# ============================================
# Optional: Database secret ARN from AWS Secrets Manager
database_secret_arn = "arn:aws:secretsmanager:us-east-1:123456789012:secret:golang-app/production/database-AbCdEf"

# Optional: SSM Parameter Store paths the application needs
parameter_store_paths = [
    "/golang-app/production/api-key",
    "/golang-app/production/jwt-secret"
]

# Optional: S3 bucket ARNs the application needs access to
s3_bucket_arns = [
    "arn:aws:s3:::golang-app-production-uploads",
    "arn:aws:s3:::golang-app-production-uploads/*"
]

# Enable ECS Exec for debugging (disable in production)
enable_execute_command = false