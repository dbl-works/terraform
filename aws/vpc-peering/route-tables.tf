#
# Requester's side of the connection
#
resource "aws_route_table" "requester_table" {
  vpc_id = var.requester_vpc_id

  tags = {
    Side        = "Requester"
    Name        = "${var.project}-${var.environment}-${var.requester_region}-${var.accepter_region}"
    Project     = var.project
    Environment = var.environment
  }
}

resource "aws_route" "requester_route" {
  route_table_id            = aws_route_table.requester_table.id
  destination_cidr_block    = var.accepter_cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.peer.id

  depends_on = [
    aws_route_table.requester_table,
    aws_vpc_peering_connection.peer,
  ]
}

resource "aws_route" "requester_route_nats" {
  count                     = length(var.requester_nat_route_table_ids)
  route_table_id            = var.requester_nat_route_table_ids[count.index]
  destination_cidr_block    = var.accepter_cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
}



#
# Accepter's side of the connection
#
resource "aws_route_table" "accepter_table" {
  provider = aws.peer
  vpc_id   = var.accepter_vpc_id

  tags = {
    Side        = "Accepter"
    Name        = "${var.project}-${var.environment}-${var.accepter_region}-${var.requester_region}"
    Project     = var.project
    Environment = var.environment
  }
}

resource "aws_route" "accepter_route" {
  provider                  = aws.peer
  route_table_id            = aws_route_table.accepter_table.id
  destination_cidr_block    = var.requester_cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection_accepter.peer.id

  depends_on = [
    aws_route_table.accepter_table,
    aws_vpc_peering_connection_accepter.peer,
  ]
}

resource "aws_route" "accepter_route_nats" {
  provider                  = aws.peer
  count                     = length(var.accepter_nat_route_table_ids)
  route_table_id            = var.accepter_nat_route_table_ids[count.index]
  destination_cidr_block    = var.requester_cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection_accepter.peer.id
}
