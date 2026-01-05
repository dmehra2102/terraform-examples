data "http" "aws_lb_policy" {
    url = "https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/main/docs/install/iam_policy.json"

    # Optional request headers
    request_headers = {
        Accept = "application/json"
    }
}

locals {
    aws_lb_policy = data.http.aws_lb_policy.response_body
}