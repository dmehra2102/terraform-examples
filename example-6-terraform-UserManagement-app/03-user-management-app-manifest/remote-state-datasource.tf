data "terraform_remote_state" "eks_cluster" {
    backend = "s3"

    config = {
        bucket  = "terraform-cluster-example"
        key     = "terraform.tfstate"
        region  = "ap-south-1"
    }
}