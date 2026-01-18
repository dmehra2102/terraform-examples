variable "project_name" {
    description = "Project name for resource naming"
    type        = string
}

variable "environment" {
    description = "Environment name"
    type        = string
}

variable "image_tag_mutability" {
    description = "Tag mutability setting for the repository"
    type        = string
}

variable "untagged_image_expiration_days" {
    description = "Days after which untagged images expire"
    type        = number
}

variable "common_tags" {
    description = "Common tags to apply to all resources"
    type        = map(string)
}