#
# https://aws.amazon.com/premiumsupport/knowledge-center/ecs-fargate-static-elastic-ip-address/
# https://aws.amazon.com/premiumsupport/knowledge-center/nat-gateway-vpc-private-subnet/
#
data "aws_eip" "main" {
  count     = length(var.public_ips)
  public_ip = var.public_ips[count.index]
}

resource "aws_nat_gateway" "main" {
  count         = length(var.public_ips)
  allocation_id = data.aws_eip.main[count.index].id
  subnet_id     = var.subnet_public_ids[count.index]
  tags = {
    Name        = "${var.project}-${var.environment}-${count.index}"
    Environment = var.environment
    Project     = var.project
  }
}

resource "aws_route" "main" {
  # Do not create this route if we do not have a NAT Gateway
  count                  = length(var.public_ips) > 0 ? length(var.subnet_private_ids) : 0
  route_table_id         = aws_route_table.main[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = element(aws_nat_gateway.main, count.index).id
}

# Create route tables so elastic IPs are used for outgoing traffic
resource "aws_route_table" "main" {
  count  = length(var.subnet_private_ids)
  vpc_id = var.vpc_id

  tags = {
    Name        = "${var.project}-${var.environment}-nat-${count.index}"
    Environment = var.environment
    Project     = var.project
  }
}

# route tables for private subnets, e.g. if we want VPC peering between stacks without NATs
# running the web process in a public subnet
resource "aws_route_table_association" "main" {
  for_each  = { for idx, subnet in var.subnet_private_ids : tostring(idx) => subnet }
  subnet_id = each.value

  route_table_id = aws_route_table.main[tonumber(each.key)].id
}
