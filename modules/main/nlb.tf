
locals {
  target_ip = {
    "ap-southeast-1b" : "10.32.132.89"
    "ap-southeast-1c" :  "10.32.132.153"
    "ap-southeast-1a" : "10.32.132.25"
  } 
}


resource "aws_lb" "nlb" {
  name               = format("%s-nlb", local.general_prefix)
  internal           = false
  load_balancer_type = "network"


  subnets = var.inbound_public_subnet_ids

  enable_cross_zone_load_balancing = true
  enable_deletion_protection       = false

  tags = {
      "Name" = format("%s-nlb", local.general_prefix)
  }


}

resource "aws_lb_target_group" "nlb_tgrp" {
  name        = format("%s-target-group", local.general_prefix)
  port        = "443"
  protocol    = "TCP"
  target_type = "ip"

  # inbound vpc id
  vpc_id = var.inbound_vpc_id

  proxy_protocol_v2  = true
  preserve_client_ip = false
  health_check {
    enabled             = true
    protocol            = "TCP"
    port                = "traffic-port"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    interval            = 30
  }

  tags = {
      "Name" = format("%s-target-group", local.general_prefix)
    }
}

resource "aws_lb_target_group_attachment" "nlb_ip_inside" {
  for_each          = local.target_ip
  target_group_arn  = aws_lb_target_group.nlb_tgrp.arn
  target_id         = each.value
  availability_zone = each.key
  port              = 443
}

resource "aws_lb_listener" "nlb_listener" {
  load_balancer_arn = aws_lb.nlb.arn
  port              = "443"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nlb_tgrp.arn
  }
}

