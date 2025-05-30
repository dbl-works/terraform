resource "aws_redshiftserverless_endpoint_access" "main" {
  endpoint_name          = "${local.name}-endpoint"
  workgroup_name         = aws_redshiftserverless_workgroup.main.workgroup_name
  subnet_ids             = var.subnet_ids
  vpc_security_group_ids = [aws_security_group.redshift.id]
}
