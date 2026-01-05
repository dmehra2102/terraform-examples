variable "region" {
    type    = string
    default = "ap-south-1"
}

variable "cluster_name" {
    type    = string
    default = "prod-eks"
}

variable "node_instance_type" {
    type    = string
    default = "t3.medium"
}

variable "node_desired_capacity" {
    type    = number
    default = 3
}

# Optional: ACM certificate ARN for TLS on ALB (if you want HTTPS)
variable "acm_certificate_arn" {
    type    = string
    default = ""
}
