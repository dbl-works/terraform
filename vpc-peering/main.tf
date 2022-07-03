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


# https://docs.aws.amazon.com/kms/latest/developerguide/multi-region-keys-auth.html
# if we create a RDS read-replica in a different region, we must pass the KMS key ARN to the replica
# so that the replica can read an encrypted master DB. KMS keys by default are only accessible in their
# region, hence we must create a replica of the RDS key.
resource "aws_kms_replica_key" "replica" {
  for_each = toset(var.cross_region_kms_keys_arns)

  description             = "Multi-Region replica key"
  deletion_window_in_days = 7
  primary_key_arn         = each.key
}
