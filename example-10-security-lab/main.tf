module "vpc" {
    source  = "terraform-aws-modules/vpc/aws"
    version = "~> 6.0"

    name = "security-lab-vpc"
    cidr = "10.0.0.0/16"

    azs = ["ap-south-1a","ap-south-1b"]
    private_subnets = ["10.0.1.0/24","10.0.2.0/24"]
    public_subnets = ["10.0.101.0/24", "10.0.102.0/24"]
    enable_nat_gateway = true

    private_subnet_names = ["security-lab-private-subnet-1", "security-lab-private-subnet-2"]
    public_subnet_names = ["security-lab-public-subnet-1", "security-lab-public-subnet-2"]
}

module "eks" {
    source  = "terraform-aws-modules/eks/aws"
    version = "~> 21.0"

    name = "security-lab-cluster"
    kubernetes_version = "1.34"
    vpc_id = module.vpc.vpc_id
    subnet_ids = module.vpc.private_subnets

    endpoint_public_access = true

    authentication_mode = "API_AND_CONFIG_MAP"

    enable_cluster_creator_admin_permissions = true
}

resource "aws_iam_role" "junior_dev" {
    name = "junior-dev-role"
    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Action = "sts:AssumeRole"
                Effect = "Allow"
                Principal = {
                    AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
                }
            }
        ]
    })
}

data "aws_caller_identity" "current" {}

resource "aws_eks_access_entry" "junior_dev_access" {
    cluster_name = module.eks.cluster_name
    principal_arn = aws_iam_role.junior_dev.arn
    type = "STANDARD"
    kubernetes_groups = ["k8s-viewers"]
}

output "cluster_name" { value = module.eks.cluster_name }
output "junior_dev_role_arn" { value = aws_iam_role.junior_dev.arn }