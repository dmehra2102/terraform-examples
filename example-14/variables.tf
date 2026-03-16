# =============================================================================
# Global
# =============================================================================

variable "project_name" {
  description = "Short identifier used in resource names (e.g. 'acme'). Lowercase, no spaces."
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{1,18}[a-z0-9]$", var.project_name))
    error_message = "project_name must be 3-20 lowercase alphanumeric characters or hyphens."
  }
}

variable "environment" {
  description = "Deployment environment: production | staging | development"
  type        = string
  default     = "production"
  validation {
    condition     = contains(["production", "staging", "development"], var.environment)
    error_message = "environment must be one of: production, staging, development."
  }
}

variable "aws_region" {
  description = "Primary AWS region."
  type        = string
  default     = "ap-south-1"
}

variable "owner_team" {
  description = "Owning team email/name for cost allocation tags."
  type        = string
}

# =============================================================================
# VPC
# =============================================================================

variable "vpc_cidr" {
  description = "IPv4 CIDR block for the VPC. /16 gives 65,534 usable IPs."
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "List of AZs to deploy into. Min 3 for HA."
  type        = list(string)
  default     = ["ap-south-1a", "ap-south-1b", "ap-south-1c"]
}

variable "public_subnet_cidrs" {
  description = "CIDRs for public subnets (one per AZ). Must be within vpc_cidr."
  type        = list(string)
  default     = ["10.0.0.0/20", "10.0.16.0/20", "10.0.32.0/20"]
}

variable "private_subnet_cidrs" {
  description = "CIDRs for private app subnets (one per AZ)."
  type        = list(string)
  default     = ["10.0.48.0/20", "10.0.64.0/20", "10.0.80.0/20"]
}

variable "database_subnet_cidrs" {
  description = "CIDRs for isolated DB/MSK subnets (one per AZ). No route to internet."
  type        = list(string)
  default     = ["10.0.96.0/20", "10.0.112.0/20", "10.0.128.0/20"]
}

variable "enable_vpc_flow_logs" {
  description = "Enable VPC Flow Logs to CloudWatch for network forensics."
  type        = bool
  default     = true
}

variable "single_nat_gateway" {
  description = "Use one shared NAT GW (cost save for non-prod). Set false for production HA."
  type        = bool
  default     = false
}

# =============================================================================
# EKS
# =============================================================================

variable "cluster_version" {
  description = "Kubernetes version. Must be a version AWS EKS supports."
  type        = string
  default     = "1.30"
}

variable "cluster_endpoint_public_access" {
  description = "Allow kubectl access from the public internet (restrict via public_access_cidrs)."
  type        = bool
  default     = true
}

variable "cluster_endpoint_public_access_cidrs" {
  description = "CIDRs allowed to reach the EKS public API endpoint."
  type        = list(string)
  default     = ["0.0.0.0/0"] # CHANGE THIS: lock to your office/VPN CIDRs
}

variable "node_groups" {
  description = "Map of managed node group configurations."
  type = map(object({
    instance_types = list(string)
    capacity_type  = string # ON_DEMAND | SPOT
    min_size       = number
    max_size       = number
    desired_size   = number
    disk_size_gb   = number
    labels         = map(string)
    taints = list(object({
      key    = string
      value  = string
      effect = string
    }))
  }))
  default = {
    system = {
      instance_types = ["m6i.large", "m6a.large"]
      capacity_type  = "ON_DEMAND"
      min_size       = 2
      max_size       = 6
      desired_size   = 3
      disk_size_gb   = 50
      labels         = { "role" = "system" }
      taints         = []
    }
    workers = {
      instance_types = ["c6i.xlarge", "c6a.xlarge", "c5.xlarge"]
      capacity_type  = "SPOT"
      min_size       = 0
      max_size       = 50
      desired_size   = 3
      disk_size_gb   = 100
      labels         = { "role" = "worker" }
      taints         = []
    }
  }
}

variable "enable_karpenter" {
  description = "Deploy Karpenter for reactive, cost-optimised autoscaling."
  type        = bool
  default     = true
}

variable "karpenter_version" {
  description = "Helm chart version for Karpenter."
  type        = string
  default     = "v0.36.2"
}

# =============================================================================
# MSK / Kafka
# =============================================================================

variable "kafka_version" {
  description = "Apache Kafka version supported by Amazon MSK."
  type        = string
  default     = "3.6.0"
}

variable "kafka_broker_instance_type" {
  description = "MSK broker EC2 instance type."
  type        = string
  default     = "kafka.m5.2xlarge" # 8 vCPU, 32 GiB — good for 1M+ users
}

variable "kafka_broker_storage_gb" {
  description = "EBS storage per broker in GiB."
  type        = number
  default     = 2000 # 2 TB per broker
}

variable "kafka_replication_factor" {
  description = "Default replication factor for topics."
  type        = number
  default     = 3
}

variable "kafka_min_insync_replicas" {
  description = "Minimum ISR before producers get an ack."
  type        = number
  default     = 2
}

variable "kafka_log_retention_hours" {
  description = "Hours to retain messages. 168 = 7 days."
  type        = number
  default     = 168
}

variable "kafka_num_partitions" {
  description = "Default number of partitions per topic."
  type        = number
  default     = 12 # Tune per throughput; roughly cores × brokers
}

# =============================================================================
# Monitoring
# =============================================================================

variable "grafana_admin_password" {
  description = "Initial Grafana admin password. ROTATE immediately after deploy."
  type        = string
  sensitive   = true
}

variable "alertmanager_slack_webhook" {
  description = "Slack webhook URL for AlertManager notifications."
  type        = string
  sensitive   = true
  default     = ""
}

variable "log_retention_days" {
  description = "CloudWatch Log Group retention in days."
  type        = number
  default     = 90
}

variable "enable_cloudwatch_container_insights" {
  description = "Enable EKS Container Insights for cluster-level metrics."
  type        = bool
  default     = true
}
