variable "name_prefix" { type = string }

variable "cluster_name" { type = string }

variable "region" { type = string }

variable "vpc_id" { type = string }

variable "oidc_provider_arn" { type = string }

variable "namespace" { 
    type = string 
    default = "alb-system" 
}

variable "service_account_name" { 
    type = string
    default = "aws-load-balancer-controller" 
}

variable "chart_version" { 
    type = string 
    default = "1.14.0" 
}

variable "enable_shield" {
    type = bool
    default = false 
}

variable "enable_waf" { 
    type = bool 
    default = false 
}

variable "enable_wafv2" { 
    type = bool 
    default = true 
}

variable "tags" { 
    type = map(string) 
    default = {} 
}
