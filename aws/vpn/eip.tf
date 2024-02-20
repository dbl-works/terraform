data "aws_eip" "main" {
  public_ip = var.eip
}

resource "aws_eip_association" "main" {
  instance_id   = aws_instance.main.id
  allocation_id = data.aws_eip.main.id
}
