data "aws_ami" "bastion_ami" {
  owners      = ["099720109477"] # Canonical Ubuntu AWS account id
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}

data "template_file" "bastion_server_userdata" {
  template = file("${path.module}/script/user-data-bastion.tpl")

  vars = {
    name = "bastion"
  }
}


resource "aws_instance" "bastion" {
  ami                    = data.aws_ami.bastion_ami.id
  instance_type          = var.bastion_instance_type
  key_name               = var.ec2_key_name
  subnet_id              = aws_subnet.public_subnet[0].id
  iam_instance_profile   = aws_iam_instance_profile.bastion.name
  vpc_security_group_ids = [var.sg_bastion_id]
  user_data              = data.template_file.bastion_server_userdata.rendered

  root_block_device {
    volume_size           = var.ebs_volume_size
    volume_type           = var.ebs_volume_type
    iops                  = var.ebs_iops
    throughput            = var.ebs_throughput
    delete_on_termination = true
    encrypted             = true
    kms_key_id            = data.aws_kms_key.kms_cmk.key_id
  }

  tags = {
    Name = format("%s", local.general_prefix)
  }
}