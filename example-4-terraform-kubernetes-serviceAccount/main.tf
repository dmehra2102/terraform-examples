module "irsa_demo_pod" {
    source = "./pod"
    service_account_name = kubernetes_service_account_v1.irsa_demo_sa.metadata.0.name
}