data "aws_caller_identity" "peer" {
  provider = aws.peer
}

# Requester's side of the connection.
resource "aws_vpc_peering_connection" "peer" {
  vpc_id        = var.requester_vpc_id
  peer_vpc_id   = var.accepter_vpc_id
  peer_owner_id = data.aws_caller_identity.peer.account_id
  peer_region   = var.accepter_region
  auto_accept   = false

  tags = {
    Side        = "Requester"
    Name        = "${var.project}-${var.environment}-${var.requester_region}-${var.accepter_region}"
    Project     = var.project
    Environment = var.environment
  }
}
