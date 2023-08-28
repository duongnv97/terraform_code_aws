resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  tags = merge({
    "Name" = "${var.master_prefix}-${var.env_prefix}-${var.app_prefix}-vpc"
    },
    var.tags
  )
}

#------------------------------------------#
#          aws_subnet                      #
#------------------------------------------#

resource "aws_subnet" "private_subnet" {
  count                   = var.private_subnets == null ? 0 : length(var.private_subnets)
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.private_subnets[count.index]
  availability_zone       = var.azs[count.index]
  map_public_ip_on_launch = false

  tags = merge({
    "Name" = "${var.master_prefix}-${var.env_prefix}-${var.app_prefix}-private-subnet"
    },
    var.tags
  )
}

resource "aws_subnet" "public_subnet" {
  count                   = var.public_subnets == null ? 0 : length(var.public_subnets)
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.public_subnets[count.index]
  availability_zone       = var.azs[count.index]
  map_public_ip_on_launch = false

  tags = merge({
    "Name" = "${var.master_prefix}-${var.env_prefix}-${var.app_prefix}-public-subnet"
    },
    var.tags
  )
}

resource "aws_subnet" "database_subnet" {
  count                   = var.data_subnets == null ? 0 : length(var.data_subnets)
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.data_subnets[count.index]
  availability_zone       = var.azs[count.index]
  map_public_ip_on_launch = false

  tags = merge({
    "Name" = "${var.master_prefix}-${var.env_prefix}-${var.app_prefix}-data-subnet"
    },
    var.tags
  )
}

#------------------------------------------#
#          internet gateway                #
#------------------------------------------#
resource "aws_internet_gateway" "igw" {
  count  = var.igw_enable ? 1 : 0
  vpc_id = aws_vpc.vpc.id

  tags = merge({
    "Name" = "${var.master_prefix}-${var.env_prefix}-${var.app_prefix}-igw"
    },
    var.tags
  )
}

resource "aws_eip" "nat_gw_eip" {
  count      = var.private_subnets == null || var.igw_enable_enable == false ? 0 : length(var.private_subnets)
  vpc        = true
  depends_on = [aws_internet_gateway.igw]
}

resource "aws_nat_gateway" "vpc_nats_gw" {
  count         = var.private_subnets == null || var.igw_enable_enable == false ? 0 : length(var.private_subnets)
  subnet_id     = aws_subnet.public_subnet[count.index].id
  allocation_id = aws_eip.nat_gw_eip[count.index].id
  depends_on    = [aws_internet_gateway.igw]

  tags = merge({
    "Name" = "${var.master_prefix}-${var.env_prefix}-${var.app_prefix}-nat"
    },
    var.tags
  )
}

#------------------------------------------#
#          aws_route_table                 #
#------------------------------------------#
resource "aws_route_table" "private_route" {
  vpc_id = aws_vpc.vpc.id

  tags = merge({
    "Name" = "${var.master_prefix}-${var.env_prefix}-${var.app_prefix}-private-rt"
    },
    var.tags
  )
}

resource "aws_route_table_association" "private_route_assoc" {
  count          = length(var.private_subnets)
  subnet_id      = aws_subnet.private_subnet[count.index].id
  route_table_id = aws_route_table.private_route.id
}

resource "aws_route_table_association" "data_route_assoc" {
  count          = length(var.data_subnets)
  subnet_id      = aws_subnet.data_subnet[count.index].id
  route_table_id = aws_route_table.private_route.id
}

resource "aws_route" "private_route" {
  count                  = length(var.private_subnets)
  route_table_id         = aws_route_table.private_route.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.vpc_nats_gw[count.index].id
}

#------------------------------------------#
#          aws_route_table                 #
#------------------------------------------#
resource "aws_route_table" "public_route" {
  vpc_id = aws_vpc.vpc.id

  tags = merge({
    "Name" = "${var.master_prefix}-${var.env_prefix}-${var.app_prefix}-public-rt"
    },
    var.tags
  )
}

resource "aws_route_table_association" "public_route_assoc" {
  count          = length(var.public_subnets)
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.public_route.id
}

resource "aws_route" "public_route" {
  route_table_id         = aws_route_table.public_route.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

#------------------------------------------#
#          vpc_follow_logs                 #
#------------------------------------------#

resource "aws_flow_log" "flow_log_s3" {
  count                = var.vpc_flow_log_enable_s3 ? 1 : 0
  log_destination      = aws_s3_bucket.s3_vpc_log_bucket.arn
  log_destination_type = "s3"
  traffic_type         = "ALL"
  log_format           = "JSON"
  vpc_id               = aws_vpc.vpc.id

  tags = merge({
    "Name" = "${var.master_prefix}-${var.env_prefix}-${var.app_prefix}-folowlog_s3"
    },
    var.tags
  )

}

