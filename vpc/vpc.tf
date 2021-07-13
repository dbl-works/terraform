variable "cidr_block" { default = "10.0.0.0/16" }

resource "aws_vpc" "vpc" {
  cidr_block = var.cidr_block
  enable_dns_hostnames = true
  tags = {
    Name = "${var.project}-${var.environment}"
    Environment = var.environment
    Project = var.project
  }
}



# Primary gateway for all traffic
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "${var.project}-${var.environment}"
    Environment = var.environment
    Project = var.project
  }
}
resource "aws_route_table" "main" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "${var.project}-${var.environment}"
    Environment = var.environment
    Project = var.project
  }
}
resource "aws_route" "all" {
  route_table_id = aws_route_table.main.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.main.id
}

# DEPRECATED: This is the existing public network that allows internet access
# range 10.0.0.0 - 10.0.2.255
resource "aws_subnet" "public" {
  count = 3
  vpc_id = aws_vpc.vpc.id
  cidr_block = cidrsubnet(var.cidr_block, 8, count.index + 1)
  map_public_ip_on_launch = true
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name = "${var.project}-${var.environment}-public-${count.index + 1}"
    Environment = var.environment
    Project = var.project
  }
}
resource "aws_route_table_association" "public" {
  count = length(aws_subnet.public)
  subnet_id = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.main.id
}

# Private subnet prevents incoming traffic.
# All outgoing traffic must go via NAT gateway
# range 10.0.100.0 - 10.0.102.255
resource "aws_subnet" "private" {
  count = 3
  vpc_id = aws_vpc.vpc.id
  cidr_block = cidrsubnet(var.cidr_block, 8, count.index + 100)
  map_public_ip_on_launch = false
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name = "${var.project}-${var.environment}-private-${count.index + 1}"
    Environment = var.environment
    Project = var.project
  }
}

# Enable flowlogs for CIS compliance
resource "aws_flow_log" "reject" {
  vpc_id          = aws_vpc.vpc.id
  traffic_type    = "REJECT"
  iam_role_arn    = "arn:aws:iam::${var.account_id}:role/FlowLogsRole"
  log_destination = "arn:aws:logs:${var.region}:${var.account_id}:log-group:VPCFlowLogs"
}
