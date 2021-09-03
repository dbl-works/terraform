terraform {
  required_providers {
    ssh = {
      source = "loafoe/ssh"
      version = "0.2.2"
    }
  }
}

resource "ssh_resource" "init" {
  host = aws_instance.main.public_ip
  user = "ubuntu"
  private_key = file("${local.key_name}.pem")

  commands = [
    "sudo cat /opt/outline/access.txt"
  ]
}
