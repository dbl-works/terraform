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

resource "aws_vpc_peering_connection_options" "requester" {
  # As options can't be set until the connection has been accepted
  # create an explicit dependency on the accepter.
  vpc_peering_connection_id = aws_vpc_peering_connection_accepter.peer.id

  requester {
    allow_remote_vpc_dns_resolution = true
  }
}


# Accepter's side of the connection.
resource "aws_vpc_peering_connection_accepter" "peer" {
  provider                  = aws.peer
  vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
  auto_accept               = true

  tags = {
    Side        = "Accepter"
    Name        = "${var.project}-${var.environment}-${var.accepter_region}-${var.requester_region}"
    Project     = var.project
    Environment = var.environment
  }
}

resource "aws_vpc_peering_connection_options" "accepter" {
  provider = aws.peer
  # As options can't be set until the connection has been accepted
  # create an explicit dependency on the accepter.
  vpc_peering_connection_id = aws_vpc_peering_connection_accepter.peer.id

  accepter {
    allow_remote_vpc_dns_resolution = true
  }
}
