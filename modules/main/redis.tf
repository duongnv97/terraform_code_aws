resource "aws_cloudwatch_log_group" "redis_slowlog" {
  name = format("%s-redis-slow-log", local.general_prefix)

  retention_in_days = 7
  kms_key_id        = data.aws_kms_key.kms_cmk.arn
  tags = {
    "ExportToS3" = "true"
  }
}

resource "aws_cloudwatch_log_group" "redis_enginelog" {
  name = format("%s-redis-engine-log", local.general_prefix)

  retention_in_days = 7
  kms_key_id        = data.aws_kms_key.kms_cmk.arn
  tags = {
    "ExportToS3" = "true"
  }
}

resource "aws_security_group" "cache" {
  name        = format("%s-cache-sg", local.general_prefix)
  description = "Security Group for Redis Cache"
  vpc_id      = data.aws_vpc.selected.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = true
  }

  # ingress {
  #   from_port   = 6379
  #   to_port     = 6379
  #   protocol    = "tcp"
  #   cidr_blocks = ["10.35.50.0/24"]
  # }

  ingress {
    from_port   = 6379
    to_port     = 6379
    protocol    = "tcp"
    cidr_blocks = ["172.100.0.0/16"]
  }

  ingress {
    from_port   = 6379
    to_port     = 6379
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
  }

  tags = {
    "Name" = format("%s-cache-sg", local.general_prefix)
  }
}

resource "aws_elasticache_subnet_group" "cache" {
  name       = format("%s-cache-subnet-group", local.general_prefix)
  subnet_ids = data.aws_subnet_ids.data.ids
}

# resource "random_password" "password" {
#   length           = 16
#   special          = true
#   override_special = "!#$%&*()-_=+[]{}<>:?"
# }

resource "aws_elasticache_user" "qrcode_user" {

  user_id              = var.user_id
  user_name            = var.user_name
  access_string        = var.access_string
  engine               = "REDIS"
  passwords            = ["Vietnam!@#2023"]
  no_password_required = "false"
}

resource "aws_elasticache_user" "qrcode_user_default" {

  user_id              = var.user_id_default
  user_name            = "default"
  access_string        = "off ~* +@all"
  engine               = "REDIS"
  passwords            = ["Vietnam!@#2023"]
  no_password_required = "false"
}


resource "aws_elasticache_user_group" "qrcode_group" {
  engine        = "REDIS"
  user_group_id = var.user_group_name
  user_ids      = [aws_elasticache_user.qrcode_user_default.user_id]

  lifecycle {
    ignore_changes = [user_ids]
  }

  depends_on = [
    aws_elasticache_user.qrcode_user_default
  ]
}

resource "aws_elasticache_user_group_association" "qrcode" {
  user_group_id = aws_elasticache_user_group.qrcode_group.user_group_id
  user_id       = aws_elasticache_user.qrcode_user.user_id
}



resource "aws_elasticache_replication_group" "redis" {

  replication_group_id = format("%s-cache", local.general_prefix)
  description          = "Redis cache for Qrcode collection"
  node_type            = "cache.t4g.medium"
  # num_cache_clusters   = "2"
  multi_az_enabled     = var.multi_az_enabled
  num_node_groups         = var.cluster_mode_num_node_groups
  replicas_per_node_group = var.cluster_mode_replicas_per_node_group

  engine               = "redis"
  engine_version       = "7.0"
  parameter_group_name = "default.redis7.cluster.on"
  port                 = 6379

  at_rest_encryption_enabled = true
  kms_key_id                 = data.aws_kms_key.kms_cmk.arn

  transit_encryption_enabled = true
  user_group_ids             = [aws_elasticache_user_group.qrcode_group.user_group_id]

  subnet_group_name  = aws_elasticache_subnet_group.cache.name
  security_group_ids = [aws_security_group.cache.id]

  final_snapshot_identifier  = false
  snapshot_retention_limit   = 7
  snapshot_window            = "17:00-18:00"
  maintenance_window         = "sat:20:00-sat:23:00"
  auto_minor_version_upgrade = false
  automatic_failover_enabled = true
  apply_immediately          = true
  # cluster_mode_enabled       = true


  log_delivery_configuration {
    destination      = format("%s-redis-slow-log", local.general_prefix)
    destination_type = "cloudwatch-logs"
    log_format       = "text"
    log_type         = "slow-log"
  }

  log_delivery_configuration {
    destination      = format("%s-redis-engine-log", local.general_prefix)
    destination_type = "cloudwatch-logs"
    log_format       = "text"
    log_type         = "engine-log"
  }
}
