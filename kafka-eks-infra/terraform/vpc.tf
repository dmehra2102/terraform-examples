module "vpc" {
    source  = "terraform-aws-modules/vpc/aws"
    version = "6.6.0"

    name = "${var.cluster_name}-vpc"
    cidr = var.vpc_cidr

    azs = var.availability_zones

    public_subnets = [
        cidrsubnet(var.vpc_cidr, 4, 0),
        cidrsubnet(var.vpc_cidr, 4, 1),
        cidrsubnet(var.vpc_cidr, 4, 2),
    ]

    # Private subnets for Kafka and EKS nodes
    private_subnets = [
        cidrsubnet(var.vpc_cidr, 4, 0), # 10.0.0.0/20
        cidrsubnet(var.vpc_cidr, 4, 1), # 10.0.16.0/20
        cidrsubnet(var.vpc_cidr, 4, 2), # 10.0.32.0/20
    ]

    enable_nat_gateway = true
    single_nat_gateway = false
    one_nat_gateway_per_az = true
    enable_dns_hostnames = true
    enable_dns_support = true

    # VPC Flow Logs for security monitoring
    enable_flow_log = true
    create_flow_log_cloudwatch_iam_role = true
    create_flow_log_cloudwatch_log_group = true
    flow_log_cloudwatch_log_group_retention_in_days = 7

    # Kubernetes Specific tags for subnet discovery
    public_subnet_tags = {
        "kubernetes.io/role/elb" = "1"
        "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    }

    private_subnet_tags = {
        "kubernetes.io/role/internal-elb"           = "1"
        "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    }

    tags = merge(
        {
            Name = "${var.cluster_name}-vpc"
        },
        var.tags
    )
}

resource "aws_security_group" "vpc_endpoints" {
    name_prefix = "${var.cluster_name}-vpc-endpoints-"
    description = "Security group for VPC endpoints"
    vpc_id = module.vpc.vpc_id

    ingress {
        description = "HTTPS from VPC"
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = [ var.vpc_cidr ]
    }

    egress {
        description = "All outbound"
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"] // only resources inside the VPC can come in
    }

    tags = merge(
        {
            Name = "${var.cluster_name}-vpc-endpoints-sg"
        },
        var.tags
    )

    lifecycle {
        create_before_destroy = true // create new security group first and only then delete the old one
    }
}

# VPC Endpoints for private communication with AWS services (reduces NAT costs)
resource "aws_vpc_endpoint" "s3" {
    vpc_id = module.vpc.vpc_id
    service_name = "com.amazonaws.${var.aws_region}.s3"
    vpc_endpoint_type = "Gateway"
    route_table_ids   = module.vpc.private_route_table_ids
    tags = merge(
        {
            Name = "${var.cluster_name}-s3-endpoint"
        },
        var.tags
    )
}

resource "aws_vpc_endpoint" "ecr_api" {
    vpc_id = module.vpc.vpc_id
    service_name = "com.amazonaws.${var.aws_region}.ecr.api"
    vpc_endpoint_type = "Interface"
    subnet_ids          = module.vpc.private_subnets
    security_group_ids  = [aws_security_group.vpc_endpoints.id]
    private_dns_enabled = true

    tags = merge(
        {
            Name = "${var.cluster_name}-ecr-api-endpoint"
        },
        var.tags
    )
}

resource "aws_vpc_endpoint" "ecr_dkr" {
    vpc_id = module.vpc.vpc_id
    service_name = "com.amazonaws.${var.aws_region}.ecr.dkr"
    vpc_endpoint_type = "Interface"
    subnet_ids          = module.vpc.private_subnets
    security_group_ids  = [aws_security_group.vpc_endpoints.id]
    private_dns_enabled = true

    tags = merge(
        {
            Name = "${var.cluster_name}-ecr-dkr-endpoint"
        },
        var.tags
    )
}

resource "aws_vpc_endpoint" "ec2" {
    vpc_id              = module.vpc.vpc_id
    service_name        = "com.amazonaws.${var.aws_region}.ec2"
    vpc_endpoint_type   = "Interface"
    subnet_ids          = module.vpc.private_subnets
    security_group_ids  = [aws_security_group.vpc_endpoints.id]
    private_dns_enabled = true

    tags = merge(
        {
            Name = "${var.cluster_name}-ec2-endpoint"
        },
        var.tags
    )
}

resource "aws_vpc_endpoint" "sts" {
    vpc_id              = module.vpc.vpc_id
    service_name        = "com.amazonaws.${var.aws_region}.sts"
    vpc_endpoint_type   = "Interface"
    subnet_ids          = module.vpc.private_subnets
    security_group_ids  = [aws_security_group.vpc_endpoints.id]
    private_dns_enabled = true

    tags = merge(
        {
            Name = "${var.cluster_name}-sts-endpoint"
        },
        var.tags
    )
}