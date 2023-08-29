# random rds master password
resource "random_password" "rds" {
    length = 16
    special = true
    overrride_special = "!#$%&*()-_=+[]{},.:?"
}

# cloud watch log group for db
resource "aws_cloudwatch_log_group" "rds_logs" {
  name              = "/aws/rds/${var.general_prefix}-db"
  retention_in_days = 14  # Adjust the retention period as needed
  kms_key_id = data.aws_kms_key.kms_cmk.key_id
}

# RDS Security group
resource "aws_security_group" "rds_securitygroup" {
    name = "${var.general_prefix}-db-sg"
    description = format("security group for %s RDS", var.general_prefix)
    vpc_id = aws_vpc.vpc.id
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = var.vpc_cidr
  }
  
}

# RDS subnetgroup
resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "${var.general_prefix}-subnet-group"
  description = "My PostgreSQL subnet group"

  subnet_ids = aws_subnet.database_subnet[*].id
}
#RDS parameter group
resource "aws_db_parameter_group" "rds_parameter_group" {
  name        = "${var.general_prefix}-parameter-group"
  family      = "postgres15"
  description = "parameter group 15"
}
# RDS postgre
resource "aws_db_instance" "rds_instance" {
  identifier            = "${var.general_prefix}-db"
  engine                = "postgres"
  engine_version        = "15.3-R2"
  instance_class        = var.db_instance_class
  name                  = "${var.general_prefix}"
  username              = "admin"
  password              = random_password.rds.result
  multi_az              = var.db_multi_az_enabled 

  allocated_storage     = var.db_allocate_storage
  storage_type          = "gp3"
  kms_key_id            = data.aws_kms_key.kms_cmk.key_id

  parameter_group_name = aws_db_parameter_group.rds_parameter_group.name

  publicly_accessible  = false
  db_subnet_group_name = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids = [aws_security_group.rds_securitygroup.id]
  port                  = "5432"


  auto_minor_version_upgrade = false
  allow_major_version_upgrade = false
  deletion_protection = false # change true on PROD
  performance_insights_enabled = false
  

  tags = {
    Name = "${var.general_prefix}-db"
  }
}
# RDS proxy
resource "aws_db_proxy" "rds_proxy" {
  name              = "${var.general_prefix}-proxy"
  engine_family     = "POSTGRESQL"
  debug_logging     = false
  idle_client_timeout = 1800
  require_tls       = true
  role_arn          = aws_iam_role.rds_role.arn
  vpc_subnet_ids    = aws_subnet.database_subnet[*].id

#   auth {
#     auth_scheme = "SECRETS"
#     iam_auth    = "DISABLED"
#   }

  tags = {
    Name = "${var.general_prefix}-proxy"
  }
}

resource "aws_db_proxy_target" "rds_proxy_target" {
  db_proxy_name = aws_db_proxy.rds_proxy.name
  target_group_name   = "${var.general_prefix}-db-target"
  db_instance_identifier  = aws_db_instance.rds_instance.id
}

resource "aws_cloudwatch_log_subscription" "rds_subcription" {
  name                = "${var.general_prefix}-db-export"
  destination_arn     = aws_cloudwatch_log_group.rds_logs.arn
  filter_pattern      = ""
  log_group_name      = aws_cloudwatch_log_group.rds_logs.name
  role_arn            = aws_iam_role.rds_role.arn
}

resource "aws_iam_role" "rds_role" {
  name = "${var.general_prefix}-proxy-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "rds.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}