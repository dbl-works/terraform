resource "aws_redshiftserverless_workgroup" "main" {
  namespace_name = aws_redshiftserverless_namespace.main.namespace_name
  workgroup_name = "${var.project}-${var.environment}"

  # Compute capacity (RPUs - Redshift Processing Units)
  base_capacity = 32  # Start with minimum capacity, can be adjusted

  # Database configuration parameters
  # Enable automatic materialized views - Redshift automatically creates and maintains
  # materialized views to speed up frequently used queries without manual intervention
  config_parameter {
    parameter_key   = "auto_mv"
    parameter_value = "true"
  }

  # Set date format to ISO standard (YYYY-MM-DD) with Month-Day-Year input preference
  # This ensures consistent date formatting across applications and makes dates human-readable
  config_parameter {
    parameter_key   = "datestyle"
    parameter_value = "ISO, MDY"
  }

  # Define schema search path - when queries don't specify a schema, Redshift will search:
  # 1. User's personal schema (if it exists)
  # 2. The public schema (default for most tables)
  # This follows PostgreSQL conventions and ensures queries work as expected
  config_parameter {
    parameter_key   = "search_path"
    parameter_value = "$user, public"
  }

  # Security and networking
  subnet_ids         = var.subnet_ids
  security_group_ids = [aws_security_group.redshift.id]

  # Enable public accessibility only if needed (usually false for security)
  publicly_accessible = false

  tags = {
    Name        = "${var.project}-${var.environment}"
    Project     = var.project
    Environment = var.environment
  }
}
