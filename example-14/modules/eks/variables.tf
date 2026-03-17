variable "name_prefix"         { type = string }
variable "cluster_name"        { type = string }
variable "cluster_version"     { type = string }
variable "aws_region"          { type = string }
variable "account_id"          { type = string }
variable "vpc_id"              { type = string }
variable "private_subnet_ids"  { type = list(string) }
variable "public_subnet_ids"   { type = list(string) }
variable "kms_key_arn"         { type = string }
variable "enable_karpenter"    { 
    type = bool 
    default = true 
}
variable "karpenter_version"   { 
    type = string 
    default = "v0.36.2" 
}
variable "cluster_endpoint_public_access" {
    type    = bool
    default = true
}
variable "cluster_endpoint_public_access_cidrs" {
    type    = list(string)
    default = ["0.0.0.0/0"]
}

variable "node_groups" {
    type = map(object({
            instance_types = list(string)
            capacity_type  = string
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
}