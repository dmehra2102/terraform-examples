resource "kubernetes_storage_class_v1" "ebs_storage_class" {
    metadata {
        name = "ebs-storage-class"
    }
    allow_volume_expansion = true
    storage_provisioner = "ebs.csi.aws.com"
    volume_binding_mode = "WaitForFirstConsumer"
}