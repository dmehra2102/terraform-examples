data "terraform_remote_state" "my_vpc" {
    backend = "s3"

    config = {
        bucket = "terraform-networking-example"
        key = "terraform.tfstate"
        region = "ap-south-1"
    }
}