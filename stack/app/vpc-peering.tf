module "vpc-peering" {
  source = "../../vpc-peering"
  count  = var.rds_is_read_replica ? 1 : 0

  providers = {
    aws.default = aws.default
    aws.peer    = aws.peer
  }

  project     = var.project
  environment = var.environment

  requester_region = var.region
  requester_vpc_id = module.vpc.id

  accepter_region = var.rds_master_db_region
  accepter_vpc_id = var.rds_master_db_vpc_id
}
