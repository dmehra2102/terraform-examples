data "aws_availability_zones" "availability_zones" {
    region = var.aws_region
    filter {
        name = "opt-in-status"
        values =[ "opt-in-not-required" ]
    }
}