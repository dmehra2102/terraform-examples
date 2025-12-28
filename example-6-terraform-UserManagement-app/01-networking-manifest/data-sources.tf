data "aws_availability_zones" "availability_zones" {
    region = "ap-south-1"
    filter {
        name = "opt-in-status"
        values = ["opt-in-not-required"]
    }
    filter {
        name = "zone-type"
        values = ["availability-zone"]
    }
}