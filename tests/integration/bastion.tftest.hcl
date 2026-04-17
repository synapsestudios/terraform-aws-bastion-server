variables {
  namespace   = "bastion-integ"
  environment = "test"
  tags        = { ApplicationName = "bastion-integration" }
}

run "setup" {
  module {
    source = "./tests/setup"
  }
  variables {
    namespace = var.namespace
  }
}

run "apply_bastion" {
  variables {
    vpc_id              = run.setup.vpc_id
    subnet_id           = run.setup.public_subnet_id
    allowed_cidr_blocks = [run.setup.runner_ingress_cidr]
  }

  assert {
    condition     = can(regex("^([0-9]{1,3}\\.){3}[0-9]{1,3}$", output.public_ip))
    error_message = "public_ip output must be a valid IPv4 address"
  }

  assert {
    condition     = length(output.ssh_key_name) > 0
    error_message = "ssh_key_name output must be populated"
  }
}

run "eip_associated" {
  variables {
    vpc_id              = run.setup.vpc_id
    subnet_id           = run.setup.public_subnet_id
    allowed_cidr_blocks = [run.setup.runner_ingress_cidr]
  }

  assert {
    condition     = aws_eip.lb.instance != null && aws_eip.lb.instance != ""
    error_message = "EIP must be associated with the bastion instance"
  }

  assert {
    condition     = aws_eip.lb.association_id != null && aws_eip.lb.association_id != ""
    error_message = "EIP must have a populated association_id after apply"
  }
}

run "secret_version_written" {
  variables {
    vpc_id              = run.setup.vpc_id
    subnet_id           = run.setup.public_subnet_id
    allowed_cidr_blocks = [run.setup.runner_ingress_cidr]
  }

  assert {
    condition     = aws_secretsmanager_secret_version.this.version_id != null && aws_secretsmanager_secret_version.this.version_id != ""
    error_message = "Secrets Manager secret version must be populated after apply"
  }
}

run "ssh_reachable" {
  module {
    source = "./tests/integration/ssh-check"
  }
  variables {
    host        = run.apply_bastion.public_ip
    secret_name = run.apply_bastion.ssh_key_name
  }
}
