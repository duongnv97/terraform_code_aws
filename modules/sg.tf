resource "aws_security_group" "cluster" {
  name        = format("%s-cluster-sg", local.general_prefix)
  description = "EKS cluster security group."
  vpc_id      = aws_vpc.vpc.id

  tags = merge(
    var.tags,
    {
      "Name" = format("%s-cluster-sg", local.general_prefix)
    },
  )
}

resource "aws_security_group_rule" "cluster_egress_internet" {
  description       = "Allow cluster egress access to the Internet."
  protocol          = "-1"
  security_group_id = aws_security_group.cluster.id
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  to_port           = 0
  type              = "egress"
}

resource "aws_security_group_rule" "cluster_https_worker_ingress" {
  description       = "Allow pods to communicate with the EKS cluster API."
  protocol          = "tcp"
  security_group_id = aws_security_group.cluster.id
  cidr_blocks       = var.aws_private_subnet_node
  from_port         = 443
  to_port           = 443
  type              = "ingress"
}

# resource "aws_security_group_rule" "cluster_private_access_cidrs_source" {
#   description = "Allow private K8S API ingress from custom CIDR source."
#   type        = "ingress"
#   from_port   = 443
#   to_port     = 443
#   protocol    = "tcp"
#   cidr_blocks = [each.value]

#   security_group_id = aws_eks_cluster.this[0].vpc_config[0].cluster_security_group_id
# }

# resource "aws_security_group_rule" "cluster_private_access_sg_source" {
#   description              = "Allow private K8S API ingress from custom Security Groups source."
#   type                     = "ingress"
#   from_port                = 443
#   to_port                  = 443
#   protocol                 = "tcp"
#   source_security_group_id = var.cluster_endpoint_private_access_sg[count.index]

#   security_group_id = aws_eks_cluster.this[0].vpc_config[0].cluster_security_group_id
# }