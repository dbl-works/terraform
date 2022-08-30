module "fivetran" {
  source = "../fivetran"

  # https://fivetran.com/docs/rest-api/connectors/config#postgres
  source_service = "postgres_rds"
  # postgres config
  #  {
  #         "schema_prefix": "test_postgres",
  #         "host": "postgresinstance.mycompany.com",
  #         "port": 5432,
  #         "database": "postgres",
  #         "user": "test_user",
  #         "password": "test_password",
  #         "tunnel_host": "XXX.XXX.XXX.XXX",
  #         "tunnel_port": 22,
  #         "tunnel_user": "fivetran",
  #         "update_method": "WAL",
  #         "replication_slot": "test_replication_slot"
  #     }
  db_config = var.db_config

  # https://fivetran.com/docs/rest-api/destinations/config#snowflake
  destionation_service  = "snowflake"
  destination_user_name = ""
  destination_password  = ""

  fivetran_group_name   = "snowflake-analytics"
}
