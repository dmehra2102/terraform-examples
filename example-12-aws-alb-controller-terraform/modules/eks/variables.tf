variable "name_prefix" { type = string }
variable "cluster_version" { type = string }
variable "vpc_id" { type = string }

variable "private_subnet_ids" {
    type = list(string)
}

variable "worker_instance_types" {
    type = list(string)
}

variable "worker_desired_size" { type = number }
variable "worker_min_size" { type = number }
variable "worker_max_size" { type = number }
variable "enable_spot_instances" { type = bool }
variable "common_tags" { type = map(string) }

variable "node_ami_type" {
    type        = string
    default     = "AL2_x86_64"
    description = "AMI type for node group"
}

variable "node_disk_encrypted" {
    description = "Whether to encrypt the root block device"
    type        = bool
    default     = true
}

variable "node_disk_type" {
    description = "Type of disk volume to use"
    type        = string
    default     = "gp3"
    
    validation {
        condition     = contains(["gp2", "gp3", "io1", "io2"], var.node_disk_type)
        error_message = "Disk type must be one of: gp2, gp3, io1, io2."
    }
}