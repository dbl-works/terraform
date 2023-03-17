data "aws_db_instance" "main" {
  db_instance_identifier = var.db_identifier
}

data "aws_secretsmanager_secret_version" "terraform" {
  secret_id = "${var.project}/terraform/${var.environment}"
}

locals {
  credentials = jsondecode(
    data.aws_secretsmanager_secret_version.terraform.secret_string
  )
}

resource "null_resource" "database_script" {
  provisioner "local-exec" {
    command = <<-EOF
      ssh -o "ServerAliveInterval=5" -o "ServerAliveCountMax=60" -fNg -L 5433:$RDS_ENDPOINT root@$BASTION_HOST
      while read line; do
        echo "$line"
      done  < <(awk -v ENVIRONMENT="$ENVIRONMENT" -v PROJECT="$PROJECT" -v DB_NAME="$DB_NAME" 'BEGIN{RS=";\n"}{gsub(/\n/,""); gsub(/{project}/, PROJECT); gsub(/{environment}/, ENV); gsub(/{db_name}/, DB_NAME); if(NF>0) {print $0";"}}' db_readonly_role.sql)
      # Close the connection of 5433 port
      lsof -ti:5433 | xargs kill 5433
    EOF


    environment = {
      RDS_ENDPOINT = data.aws_db_instance.main.endpoint
      DB_NAME      = data.aws_db_instance.main.db_name
      PGPASSWORD   = local.credentials.db_root_password
      BASTION_HOST = "${var.bastion_subdomain}.${var.domain_name}"
      PROJECT      = replace(var.project, "-", "_")
      ENVIRONMENT  = var.environment
    }

    interpreter = ["bash", "-c"]
  }
}


# psql -U root -h localhost -p 5433 -d $DB_NAME -c "$line"
