# Copy this file to terraform.tfvars and update with your values 
aws_region = "ap-south-1" 
environment = "prod" 
project_name = "myapp" 
cluster_name = "myapp-prod-eks" 
kubernetes_version = "1.34" 

# VPC Configuration
vpc_id = "vpc-0608940f524ec1daf" 
private_subnet_ids = [ "subnet-0b3e635d82834a95c", "subnet-0418c3bcd734a621b", "subnet-0b01aa6761226ca15" ]
vpc_cidr_block = "10.0.0.0/16"

# Node Configuration 
desired_node_count = 3 
node_instance_types = ["t3.medium"] 
node_disk_size = 20

# Cluster Access 
cluster_endpoint_public_access = true 
cluster_endpoint_private_access = true 

# Addons 
enable_vpc_cni = true

# Logging
enable_logging = true 
log_retention_days = 30 

# IAM Users and Roles for Cluster Access 
admin_users = [ "yogita-free-iam-user-dec-2025", "jane.smith" ] 
# admin_roles = [ "arn:aws:iam::123456789012:role/github-actions-admin" ] 
developer_users = [ "dev.engineer1" ] 
# developer_roles = [ "arn:aws:iam::123456789012:role/ci-cd-developer" ] 
reader_users = [ "audit.reviewer" ] 
# reader_roles = [ "arn:aws:iam::123456789012:role/monitoring-readonly" ] 
devops_users = [ "devops.manager" ] 
# devops_roles = [ "arn:aws:iam::123456789012:role/devops-automation" ] 

# Additional Tags 
tags = { 
    CostCenter = "engineering" 
    Owner = "platform-team" 
    Terraform = "true" 
}