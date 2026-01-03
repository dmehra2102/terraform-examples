locals {
    cluster_name = "${var.project_name}-${var.environment}"
    
    common_tags = merge(
        var.tags,
        {
        Cluster     = local.cluster_name
        Environment = var.environment
        Project     = var.project_name
        ManagedBy   = "Terraform"
        }
    )
    
    # Auto-scaling configuration
    karpenter_enabled = var.environment != "dev" ? true : false
    
    # Monitoring
    prometheus_enabled = var.enable_monitoring && var.environment != "dev"
}
