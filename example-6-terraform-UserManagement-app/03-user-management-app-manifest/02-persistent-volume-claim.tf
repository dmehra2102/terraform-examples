resource "kubernetes_persistent_volume_claim_v1" "ebs_pvc" {
    metadata {
        name = "ebs-mysl-pv-claim"
    }

    spec {
        access_modes = [ "ReadWriteOnce" ]
        storage_class_name = kubernetes_storage_class_v1.ebs_storage_class.metadata.0.name
        resources {
            requests = {
                storage = "4Gi"
            }
        }
    }
    
    wait_until_bound = true
}