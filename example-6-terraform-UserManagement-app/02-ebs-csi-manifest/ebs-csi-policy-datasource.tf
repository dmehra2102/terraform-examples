data "http" "ebs_csi_policy_data" {
    url = "https://raw.githubusercontent.com/kubernetes-sigs/aws-ebs-csi-driver/master/docs/example-iam-policy.json"

    request_headers = {
        Accept = "application/json"
    }
}