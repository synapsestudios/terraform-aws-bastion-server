terraform {
  required_providers {
    aws  = { source = "hashicorp/aws", version = "~> 5.0" }
    null = { source = "hashicorp/null", version = "~> 3.0" }
  }
}

data "aws_secretsmanager_secret" "key" {
  name = var.secret_name
}

data "aws_secretsmanager_secret_version" "key" {
  secret_id = data.aws_secretsmanager_secret.key.id
}

resource "null_resource" "ssh_check" {
  triggers = {
    host = var.host
  }

  connection {
    type        = "ssh"
    host        = var.host
    user        = "ec2-user"
    private_key = data.aws_secretsmanager_secret_version.key.secret_string
    timeout     = "3m"
  }

  provisioner "remote-exec" {
    inline = ["echo 'Hello, World'"]
  }
}
