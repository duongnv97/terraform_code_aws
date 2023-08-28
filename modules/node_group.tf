data "aws_ami" "eks_node_ami" {
  owners      = ["602401143452"]
  most_recent = true

  filter {
    name   = "name"
    values = ["amazon-eks-node-${aws_eks_cluster.cg_cluster_api.version}-*"]
  }
}

resource "aws_launch_template" "workers" {

  description            = format("EKS Managed Node Group custom LT for %s", local.general_prefix)
  update_default_version = true

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size           = var.node_volume_size
      volume_type           = var.ebs_volume_type
      iops                  = var.ebs_iops
      throughput            = var.ebs_throughput
      kms_key_id            = data.aws_kms_key.kms_cmk.key_id
      delete_on_termination = true
      encrypted             = true
    }
  }

  # if you want to use a custom AMI
  image_id = data.aws_ami.eks_node_ami.id
  key_name = var.ec2_key_pair

  metadata_options {
    http_endpoint               = "enable"
    http_tokens                 = "required"
    http_put_response_hop_limit = 2
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_eks_node_group" "workers" {

  node_group_name = format("%s-service_node", local.general_prefix)
  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_role_arn   = aws_iam_role.eks_node.arn
  subnet_ids      = aws_subnet.private_subnet[*].id
  image_id        = data.aws_ami.eks_node_ami.id
  instance_types  = sort(var.instance_type)

  scaling_config {
    desired_size = var.desired_size
    max_size     = var.max_size
    min_size     = var.min_size
  }

  launch_template {
    id      = aws_launch_template.workers.id
    version = "$Latest"
  }

  dynamic "update_config" {
    for_each = var.update_config

    content {
      max_unavailable            = lookup(update_config.value, "max_unavailable", null)
      max_unavailable_percentage = lookup(update_config.value, "max_unavailable_percentage", null)
    }
  }


  dynamic "timeouts" {
    for_each = var.node_group_terraform_timeouts
    content {
      create = timeouts.value["create"]
      update = timeouts.value["update"]
      delete = timeouts.value["delete"]
    }
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_worker_node_policy,
    aws_iam_role_policy_attachment.eks_cni,
    aws_iam_role_policy_attachment.ec2_container,
    aws_iam_role_policy_attachment.s3_full_policy,
    aws_iam_role_policy_attachment.ssm_full,
    aws_launch_template.workers
  ]
}
