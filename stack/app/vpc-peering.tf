module "vpc-peering" {
  source = "../../vpc-peering"
  count  = var.vpc_peering ? 1 : 0

  providers = {
    aws      = aws
    aws.peer = aws.peer
  }

  project     = var.project
  environment = var.environment

  requester_region     = var.region
  requester_vpc_id     = module.vpc.id
  requester_cidr_block = var.vpc_cidr_block
  requester_nat_route_table_ids = flatten(concat(
    module.nat[*].aws_route_table_ids,
    module.vpc.route_table_ids,

  ))

  accepter_region              = var.rds_master_db_region
  accepter_vpc_id              = var.rds_master_db_vpc_id
  accepter_cidr_block          = var.rds_master_db_vpc_cidr_block
  accepter_nat_route_table_ids = var.rds_master_nat_route_table_ids
}
