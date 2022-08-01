# Requester's side of the connection.
resource "aws_route_table" "requester_table" {
  vpc_id = var.requester_vpc_id
}

resource "aws_route" "requester_route" {
  route_table_id            = aws_route_table.requester_table.id
  destination_cidr_block    = var.accepter_cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
}


# Accepter's side of the connection.
resource "aws_route_table" "accepter_table" {
  provider = aws.peer
  vpc_id   = var.accepter_vpc_id
}

resource "aws_route" "accepter_route" {
  provider                  = aws.peer
  route_table_id            = aws_route_table.accepter_table.id
  destination_cidr_block    = var.requester_cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
}
