
variable "namespace" { 
    type = string
    default = "app" 
}

variable "pod_security_level" { 
    type = string 
    default = "restricted" 
}

variable "ingress_controller_namespace" { 
    type = string
    default = "alb-system" 
}

variable "app_name" { 
    type = string 
    default = "dummy-app" 
}

variable "image" { 
    type = string 
    default = "public.ecr.aws/docker/library/nginx:stable" 
}

variable "replicas" { 
    type = number 
    default = 2 
}

variable "alb_scheme" { 
    type = string 
    default = "internet-facing" 
}

variable "alb_group_name" { 
    type = string
    default = "apps" 
}

variable "public_subnet_ids" { 
    type = list(string) 
}

variable "alb_sg_id" { 
    type = string 
}
