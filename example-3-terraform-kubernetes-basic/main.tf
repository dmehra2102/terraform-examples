module "kubernetes_deployment" {
    source = "./deployments"
}

module "kubernetes_pods" {
    source = "./pods"
}