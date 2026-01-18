# ===============================
# ECR Repository
# ===============================
resource "aws_ecr_repository" "main" {
    name = "${var.project_name}-${var.environment}"
    image_tag_mutability = var.image_tag_mutability

    image_scanning_configuration {
        scan_on_push = true
    }

    encryption_configuration {
        encryption_type = "AES256"
    }
    
    tags = merge(var.common_tags, {
        Name = "${var.project_name}-${var.environment}-ecr"
    })
}

# ============================================
# ECR Lifecycle Policy
# ============================================
resource "aws_ecr_lifecycle_policy" "main" {
    repository = aws_ecr_repository.main.name

    policy = jsonencode({
        rules = [
            {
                "rulePriority": 1,
                "description": "Keep last 5 tagged images",
                "selection": {
                    "tagStatus": "tagged",
                    "tagPrefixList" = ["v", "release", "latest"],
                    "countType": "imageCountMoreThan",
                    "countNumber": 5
                },
                "action": {
                    "type": "expire"
                }
            },
            {
                "rulePriority": 2,
                "description": "Expire untagged images after ${var.untagged_image_expiration_days} days",
                "selection": {
                    "tagStatus": "untagged",
                    "countType": "sinceImagePushed",
                    "countUnit": "days",
                    "countNumber": var.untagged_image_expiration_days
                },
                "action": {
                    "type": "expire"
                }
            }
        ]
    })
}