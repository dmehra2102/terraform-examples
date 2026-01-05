output "cluster_name" {
    value = module.eks.cluster_id
}

output "kubeconfig_command" {
  value = "aws eks update-kubeconfig --name ${module.eks.cluster_id} --region ${var.region}"
}

output "alb_controller_iam_role_arn" {
    value = aws_iam_role.alb_controller.arn
}

output "alb_controller_helm_status" {
    value = helm_release.aws_lb_controller.status
}
