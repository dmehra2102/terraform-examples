variable "name_prefix" {
    type = string
    description = "Prefix for naming KMS resources."
}

variable "kms_key_policy_json" {
    type = string
    description = "Optional explicit KMS key policy JSON."
    default = ""
}

variable "tags" {
    type = map(string)
    description = "Common tags"
    default = {}
}