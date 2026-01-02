# IAM Role for Worker Node Group
resource "aws_iam_role" "node_group_role" {
    name = "${var.project_name}-node-group-role"
    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Action = "sts:AssumeRole"
                Effect = "Allow"
                Principal = {
                    Service = "ec2.amazonaws.com"
                }
            }
        ]
    })
}

resource "aws_iam_role_policy_attachment" "node_group_policy" {
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
    role       = aws_iam_role.node_group_role.name
}

resource "aws_iam_role_policy_attachment" "cni_policy" {
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
    role       = aws_iam_role.node_group_role.name
}

resource "aws_iam_role_policy_attachment" "registry_policy" {
    policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
    role       = aws_iam_role.node_group_role.name
}

resource "aws_security_group" "worker_nodes" {
    name        = "${var.project_name}-worker-node-sg"
    description = "Security group for EKS worker nodes"
    vpc_id      = aws_vpc.main.id

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "${var.project_name}-worker-node-sg"
    }
}

# Create the Blueprint (Launch Template)
resource "aws_launch_template" "nodes" {
    name_prefix = "${var.project_name}-node-lt"
    vpc_security_group_ids = [aws_security_group.worker_nodes.id]

    tag_specifications {
        resource_type = "instance"
        tags = {
            Name = "${var.project_name}-node"
        }
    }

    lifecycle {
        create_before_destroy = true
    }
}

resource "aws_eks_node_group" "main" {
    node_group_name = "${var.project_name}-node-group"
    cluster_name    = aws_eks_cluster.main.name
    subnet_ids      = aws_subnet.private[*].id
    node_role_arn   = aws_iam_role.node_group_role.arn
    version         = var.eks_cluster_version

    launch_template {
        id      = aws_launch_template.nodes.id
        version = aws_launch_template.nodes.latest_version
    }

    scaling_config {
        desired_size = var.node_group_desired_size
        max_size     = var.node_group_max_size
        min_size     = var.node_group_min_size
    }

    update_config {
        max_unavailable_percentage = 50
    }

    instance_types = var.node_instance_types

    tags = {
        Name = "${var.project_name}-node-group"
    }

    depends_on = [ 
        aws_iam_role_policy_attachment.cni_policy,
        aws_iam_role_policy_attachment.registry_policy,
        aws_iam_role_policy_attachment.node_group_policy,
        aws_security_group.worker_nodes 
    ]

    lifecycle {
        create_before_destroy = true
    }
}