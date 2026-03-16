locals {
	nat_gateway_count = var.single_nat_gateway ? 1 : length(var.availability_zones)
}

# ====================================================
# VPC
# ====================================================
resource "aws_vpc" "main" {
    cidr_block = var.vpc_cidr
    enable_dns_hostnames = true
    enable_dns_support = true

    tags = {
        Name = "${var.name_prefix}-vpc"
        # EKS needs these tags to discover the VPC
        "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    }
}

# =====================================================
# INTERNET GATEWAY
# =====================================================
resource "aws_internet_gateway" "main" {
    vpc_id = aws_vpc.main.id
    tags = {
        Name = "${var.name_prefix}-igw"
    }
}

# =====================================================
# PUBLIC SUBNETS (one per AZ)
# Load balancer and NAT GW placement
# =====================================================
resource "aws_subnet" "public" {
    count = length(var.availability_zones)

    vpc_id = aws_vpc.main.id
    cidr_block = var.public_subnet_cidrs[count.index]
    availability_zone = var.availability_zones[count.index]
    map_public_ip_on_launch = true

    tags = {
        Name = "${var.name_prefix}-public-${var.availability_zones[count.index]}"
        Tier = "public"

        # Tag required for AWS Load Balancer Controller to use these subnets
        "kubernetes.io/role/elb" = "1"
        "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    }
}

# =============================================================================
# PRIVATE APP SUBNETS (one per AZ)
# EKS nodes, pods, application workloads
# =============================================================================
resource "aws_subnet" "private" {
    count = length(var.availability_zones)

    vpc_id = aws_vpc.main.id
    cidr_block = var.private_subnet_cidrs[count.index]
    availability_zone = var.availability_zones[count.index]

    tags = {
        Name = "${var.name_prefix}-private-${var.availability_zones[count.index]}"
        Tier = "private"

        # Tag required for internal load balancers
        "kubernetes.io/role/internal-elb"               = "1"
        "kubernetes.io/cluster/${var.cluster_name}"     = "shared"
        # Karpenter uses this tag to discover subnets
        "karpenter.sh/discovery"                        = var.cluster_name
    }
}

# =============================================================================
# ISOLATED / DATABASE SUBNETS (one per AZ)
# MSK brokers, RDS — NO direct internet route
# =============================================================================
resource "aws_subnet" "database" {
    count = length(var.availability_zones)

    vpc_id            = aws_vpc.main.id
    cidr_block        = var.database_subnet_cidrs[count.index]
    availability_zone = var.availability_zones[count.index]

    tags = {
        Name = "${var.name_prefix}-db-${var.availability_zones[count.index]}"
        Tier = "database"
    }
}

# =============================================================================
# ELASTIC IPs + NAT GATEWAYS
# =============================================================================
resource "aws_eip" "nat" {
    count = local.nat_gateway_count

    domain = "vpc"
    tags = {
        Name = "${var.name_prefix}-eip-nat-${count.index}"
    }
    depends_on = [ aws_internet_gateway.main ]
}

resource "aws_nat_gateway" "main" {
    count = local.nat_gateway_count

    allocation_id = aws_eip.nat[count.index].id
    subnet_id = aws_subnet.public[count.index].id
    tags = { 
        Name = "${var.name_prefix}-nat-${count.index}" 
    }
    depends_on = [aws_internet_gateway.main]
}

# =============================================================================
# ROUTE TABLES
# =============================================================================
resource "aws_route_table" "public" {
    vpc_id = aws_vpc.main.id

    route {
        gateway_id = aws_internet_gateway.main.id
        cidr_block = "0.0.0.0/0"
    }

    tags = {
        Name = "${var.name_prefix}-rt-public"
    }
}

resource "aws_route_table_association" "public" {
    count = length(var.availability_zones)
    route_table_id = aws_route_table.public.id
    subnet_id = aws_subnet.public[count.index].id
}

# --- Private: egress-only via NAT GW ---
resource "aws_route_table" "private" {
    count = length(var.availability_zones)
    vpc_id = aws_vpc.main.id

    route {
        nat_gateway_id = var.single_nat_gateway ? aws_nat_gateway.main[0].id : aws_nat_gateway.main[count.index].id

        cidr_block = "0.0.0.0/0"
    }

    tags   = { 
        Name = "${var.name_prefix}-rt-private-${var.availability_zones[count.index]}" 
    }
}

resource "aws_route_table_association" "private" {
    count = length(var.availability_zones)
    route_table_id = aws_route_table.private[count.index].id
    subnet_id = aws_subnet.private[count.index].id
}

# --- Database: no internet route (truly isolated) ---
resource "aws_route_table" "database" {
    vpc_id = aws_vpc.main.id
    tags   = { 
        Name = "${var.name_prefix}-rt-database" 
    }
}

resource "aws_route_table_association" "database" {
    count          = length(var.availability_zones)
    subnet_id      = aws_subnet.database[count.index].id
    route_table_id = aws_route_table.database.id
}

# =============================================================================
# VPC ENDPOINTS (PrivateLink — keeps traffic off internet, reduces NAT cost)
# =============================================================================
data "aws_region" "current" {}

resource "aws_vpc_endpoint" "s3" {
    vpc_id = aws_vpc.main.id
    service_name = "com.amazonaws.${data.aws_region.current.region}.s3"
    vpc_endpoint_type = "Gateway"
    route_table_ids = concat(
        [aws_route_table.public.id],
        aws_route_table.private[*].id,
        [aws_route_table.database.id]
    )
    tags = { 
        Name = "${var.name_prefix}-vpce-s3" 
    }
}

# ECR endpoints — keep image pulls off NAT
resource "aws_vpc_endpoint" "ecr_api" {
    vpc_id = aws_vpc.main.id
    service_name        = "com.amazonaws.${data.aws_region.current.region}.ecr.api"
    vpc_endpoint_type   = "Interface"
    subnet_ids = aws_subnet.private[*].id
    private_dns_enabled = true
    security_group_ids = [ aws_security_group.vpc_endpoints.id ]
    tags = { 
        Name = "${var.name_prefix}-vpce-ecr-dkr" 
    }
}

resource "aws_vpc_endpoint" "ecr_dkr" {
    vpc_id              = aws_vpc.main.id
    service_name        = "com.amazonaws.${data.aws_region.current.region}.ecr.dkr"
    vpc_endpoint_type   = "Interface"
    subnet_ids          = aws_subnet.private[*].id
    security_group_ids  = [aws_security_group.vpc_endpoints.id]
    private_dns_enabled = true
    tags = { 
        Name = "${var.name_prefix}-vpce-ecr-dkr" 
    }
}

# Secrets Manager endpoint — ESO and app pods
resource "aws_vpc_endpoint" "secretsmanager" {
    vpc_id              = aws_vpc.main.id
    service_name        = "com.amazonaws.${data.aws_region.current.region}.secretsmanager"
    vpc_endpoint_type   = "Interface"
    subnet_ids          = aws_subnet.private[*].id
    security_group_ids  = [aws_security_group.vpc_endpoints.id]
    private_dns_enabled = true
    tags = { 
        Name = "${var.name_prefix}-vpce-secretsmanager" 
    }
}

# CloudWatch Logs endpoint — Fluent Bit
resource "aws_vpc_endpoint" "logs" {
    vpc_id              = aws_vpc.main.id
    service_name        = "com.amazonaws.${data.aws_region.current.region}.logs"
    vpc_endpoint_type   = "Interface"
    subnet_ids          = aws_subnet.private[*].id
    security_group_ids  = [aws_security_group.vpc_endpoints.id]
    private_dns_enabled = true
    tags = { 
        Name = "${var.name_prefix}-vpce-logs" 
    }
}

# =============================================================================
# SECURITY GROUP: VPC Endpoints
# =============================================================================
resource "aws_security_group" "vpc_endpoints" {
    name = "${var.name_prefix}-sg-vpce"
    description = "Allow HTTPS from VPC CIDR to interface VPC endpoints"
    vpc_id = aws_vpc.main.id

    ingress {
        description = "HTTPS from VPC"
        from_port = 443
        to_port = 443
        cidr_blocks = [ var.vpc_cidr ]
    }

    egress {
        description = "Allow all egress"
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = { 
        Name = "${var.name_prefix}-sg-vpce"
    }
}

# =============================================================================
# VPC FLOW LOGS
# =============================================================================
resource "aws_cloudwatch_log_group" "flow_logs" {
    count = var.enable_flow_logs ? 1 : 0
    name = "/aws/vpc/flowlogs/${var.name_prefix}"
    retention_in_days = var.log_retention_days
    tags = {
        Name = "${var.name_prefix}-flow-logs"
    }
}

resource "aws_iam_role" "flow_logs" {
    count = var.enable_flow_logs ? 1 : 0
    name  = "${var.name_prefix}-vpc-flow-logs-role"

    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [{
            Action = "sts:AssumeRole"
            Effect = "Allow"
            Principal = {
                Service = "vpc-flow-logs.amazonaws.com"
            }
        }]
    })
}

resource "aws_iam_role_policy_attachment" "flow_logs" {
    count      = var.enable_flow_logs ? 1 : 0
    role       = aws_iam_role.flow_logs[0].name
    policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}

resource "aws_flow_log" "main" {
    count = var.enable_flow_logs ? 1 : 0

    iam_role_arn = aws_iam_role.flow_logs[0].arn
    log_destination = aws_cloudwatch_log_group.flow_logs[0].arn
    traffic_type = "ALL"
    vpc_id = aws_vpc.main.id

    tags = { 
        Name = "${var.name_prefix}-flow-log" 
    }
}