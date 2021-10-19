terraform {
  required_providers {
    ssh = {
      source  = "loafoe/ssh"
      version = "1.0.0"
    }
  }
}

resource "ssh_resource" "init" {
  host        = aws_instance.main.public_ip
  user        = "ubuntu"
  private_key = file("${var.key_name}.pem")

  commands = [
    "sudo cat /opt/outline/access.txt"
  ]
}

output "access_info" {
  value = try(jsondecode(ssh_resource.init.result), {})
}
