provider "aws" {
    region = "ap-south-1"
}

provider "kubernetes" {
    host = module.eks_cluster.eks_cluster_api_server_endpoint
    cluster_ca_certificate = base64decode(module.eks_cluster.eks_certificate_authority_data)
    token = module.eks_cluster.eks_cluster_id
}