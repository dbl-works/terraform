resource "null_resource" "database_script" {
  provisioner "local-exec" {
    command = <<-EOF
      ssh -o "ServerAliveInterval=5" -o "ServerAliveCountMax=60" -fNg -L 5433:$RDS_ENDPOINT root@$BASTION_HOST
      while read line; do
        echo "$line"
        psql -U $DB_USER -h localhost -p 5433 -d $DB_NAME -c "$line"
      done  < <(awk -v ENVIRONMENT="$ENVIRONMENT" -v PROJECT="$PROJECT" -v DB_NAME="$DB_NAME" 'BEGIN{RS=";\n"}{gsub(/\n/,""); gsub(/{project}/, PROJECT); gsub(/{environment}/, ENVIRONMENT); gsub(/{db_name}/, DB_NAME); if(NF>0) {print $0";"}}' db_readonly_role.sql)
      # Close the connection of 5433 port
      lsof -ti:5433 | xargs kill -9
    EOF


    environment = {
      RDS_ENDPOINT = var.db_endpoint
      DB_NAME      = var.db_name
      DB_USER      = nonsensitive(var.db_username)
      PGPASSWORD   = nonsensitive(var.db_root_password)
      BASTION_HOST = "${var.bastion_subdomain}.${var.domain_name}"
      PROJECT      = replace(var.project, "-", "_")
      ENVIRONMENT  = var.environment
    }

    interpreter = ["bash", "-c"]
    working_dir = path.module
  }
}
