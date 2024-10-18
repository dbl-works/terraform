data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

locals {
  account_id   = data.aws_caller_identity.current.account_id
  region       = data.aws_region.current.name
  subnet_count = length(var.availability_zones)
  subnet_keys  = [for i in range(local.subnet_count) : tostring(i)]
}

resource "aws_vpc" "vpc" {
  cidr_block           = var.cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name        = "${var.project}-${var.environment}"
    Environment = var.environment
    Project     = var.project
  }
}

# Primary gateway for all traffic
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name        = "${var.project}-${var.environment}"
    Environment = var.environment
    Project     = var.project
  }
}

resource "aws_route_table" "main" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name        = "${var.project}-${var.environment}"
    Environment = var.environment
    Project     = var.project
  }
}

resource "aws_route" "all" {
  route_table_id         = aws_route_table.main.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

# DEPRECATED: This is the existing public network that allows internet access
# range 10.0.0.0 - 10.0.2.255
resource "aws_subnet" "public" {
  for_each                = toset(local.subnet_keys)
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = cidrsubnet(var.cidr_block, 8, index(var.availability_zones, each.key) + 1)
  map_public_ip_on_launch = true
  availability_zone       = var.availability_zones[tonumber(each.key)]

  tags = {
    Name        = "${var.project}-${var.environment}-public-${index(var.availability_zones, each.key) + 1}"
    Environment = var.environment
    Project     = var.project
  }
}

resource "aws_route_table_association" "public" {
  for_each       = toset(local.subnet_keys)
  subnet_id      = aws_subnet.public[each.key].id
  route_table_id = aws_route_table.main.id
}

# Private subnet prevents incoming traffic.
# All outgoing traffic must go via NAT gateway
# range 10.0.100.0 - 10.0.102.255
resource "aws_subnet" "private" {
  for_each                = toset(local.subnet_keys)
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = cidrsubnet(var.cidr_block, 8, tonumber(each.key) + 100)
  map_public_ip_on_launch = false
  availability_zone       = var.availability_zones[tonumber(each.key)]

  tags = {
    Name        = "${var.project}-${var.environment}-private-${tonumber(each.key) + 1}"
    Environment = var.environment
    Project     = var.project
  }
}

# Enable flowlogs for CIS compliance
resource "aws_flow_log" "reject" {
  vpc_id          = aws_vpc.vpc.id
  traffic_type    = "REJECT"
  iam_role_arn    = "arn:aws:iam::${local.account_id}:role/FlowLogsRole"
  log_destination = "arn:aws:logs:${local.region}:${local.account_id}:log-group:VPCFlowLogs"
}
