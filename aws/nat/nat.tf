#
# https://aws.amazon.com/premiumsupport/knowledge-center/ecs-fargate-static-elastic-ip-address/
# https://aws.amazon.com/premiumsupport/knowledge-center/nat-gateway-vpc-private-subnet/
#

locals {
  nat_count            = length(var.public_ips)
  nat_keys             = [for i in range(local.nat_count) : tostring(i)]
  private_subnet_count = length(var.subnet_private_ids)
  private_subnet_keys  = [for i in range(local.private_subnet_count) : tostring(i)]
}

data "aws_eip" "main" {
  for_each  = toset(local.nat_keys)
  public_ip = var.public_ips[tonumber(each.key)]
}

resource "aws_nat_gateway" "main" {
  for_each      = toset(local.nat_keys)
  allocation_id = data.aws_eip.main[each.key].id
  subnet_id     = var.subnet_public_ids[tonumber(each.key)]
  tags = {
    Name        = "${var.project}-${var.environment}-${each.key}"
    Environment = var.environment
    Project     = var.project
  }
}

# Create route tables so elastic IPs are used for outgoing traffic
resource "aws_route_table" "main" {
  for_each = toset(local.nat_keys)
  vpc_id   = var.vpc_id

  tags = {
    Name        = "${var.project}-${var.environment}-nat-${each.key}"
    Environment = var.environment
    Project     = var.project
  }
}

resource "aws_route" "main" {
  for_each               = local.nat_count > 0 ? toset(local.nat_keys) : toset([])
  route_table_id         = aws_route_table.main[each.key].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.main[each.key].id
}

# route tables for private subnets, e.g. if we want VPC peering between stacks without NATs
# running the web process in a public subnet
resource "aws_route_table_association" "main" {
  for_each       = toset(local.private_subnet_keys)
  subnet_id      = var.subnet_private_ids[tonumber(each.key)]
  route_table_id = aws_route_table.main[local.nat_keys[tonumber(each.key) % length(local.nat_keys)]].id
}
