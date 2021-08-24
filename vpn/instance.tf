# ec2 instance
resource "aws_instance" "main" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  associate_public_ip_address = true # Needs to be true, even if allocating an EIP
  availability_zone           = "${var.region}a"
  key_name                    = var.key_name
  subnet_id                   = module.vpc.subnet_public_ids[0]
  vpc_security_group_ids = [
    aws_security_group.main.id,
  ]
  monitoring = true

  tags = {
    Name        = "${var.project}-${var.environment}"
    Project     = var.project
    Environment = var.environment
  }
}
