mock_provider "aws" {}

variables {
  namespace           = "bastion-unit"
  environment         = "test"
  vpc_id              = "vpc-12345678"
  subnet_id           = "subnet-12345678"
  tags                = { ApplicationName = "unit-test" }
  allowed_cidr_blocks = ["203.0.113.0/24"]
}

run "naming_conventions" {
  command = plan

  assert {
    condition     = aws_security_group.this.name == "bastion-${var.namespace}"
    error_message = "Security group name should be bastion-<namespace>"
  }

  assert {
    condition     = aws_iam_role.this.name == "${var.namespace}Role"
    error_message = "IAM role name should be <namespace>Role"
  }

  assert {
    condition     = aws_key_pair.this.key_name_prefix == var.namespace
    error_message = "Key pair key_name_prefix should equal namespace"
  }

  assert {
    condition     = aws_secretsmanager_secret.this.name_prefix == var.namespace
    error_message = "Secret name_prefix should equal namespace"
  }
}

run "sg_tag_merge" {
  command = plan

  assert {
    condition     = aws_security_group.this.tags["Name"] == "Bastion"
    error_message = "Security group should have Name=Bastion tag"
  }

  assert {
    condition     = aws_security_group.this.tags["ApplicationName"] == "unit-test"
    error_message = "Security group should merge caller-provided tags"
  }
}

run "encrypted_root_volume" {
  command = plan

  assert {
    condition     = aws_instance.this.root_block_device[0].encrypted == true
    error_message = "Root block device must be encrypted"
  }
}

run "sg_ingress_ssh_only" {
  command = plan

  assert {
    condition     = length(aws_security_group.this.ingress) == 1
    error_message = "Security group should expose exactly one ingress rule"
  }

  assert {
    condition     = tolist(aws_security_group.this.ingress)[0].from_port == 22
    error_message = "Ingress from_port should be 22"
  }

  assert {
    condition     = tolist(aws_security_group.this.ingress)[0].to_port == 22
    error_message = "Ingress to_port should be 22"
  }

  assert {
    condition     = tolist(aws_security_group.this.ingress)[0].protocol == "6"
    error_message = "Ingress protocol should be tcp (6)"
  }
}

run "sg_ingress_cidrs_from_variable" {
  command = plan

  assert {
    condition     = tolist(tolist(aws_security_group.this.ingress)[0].cidr_blocks) == var.allowed_cidr_blocks
    error_message = "Ingress cidr_blocks should come from var.allowed_cidr_blocks, not a module default"
  }
}

run "imdsv2_required" {
  command = plan

  assert {
    condition     = aws_instance.this.metadata_options[0].http_tokens == "required"
    error_message = "IMDSv2 must be required (http_tokens = required)"
  }

  assert {
    condition     = aws_instance.this.metadata_options[0].http_put_response_hop_limit == 1
    error_message = "Metadata hop limit should be 1"
  }
}

run "ssm_policy_attached" {
  command = plan

  assert {
    condition     = aws_iam_role_policy_attachment.ssm.policy_arn == "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
    error_message = "Bastion IAM role must have AmazonSSMManagedInstanceCore attached for Session Manager fallback"
  }

  assert {
    condition     = aws_iam_role_policy_attachment.ssm.role == aws_iam_role.this.name
    error_message = "SSM policy attachment must target the bastion's IAM role"
  }
}

run "instance_profile_wiring" {
  command = plan

  assert {
    condition     = aws_iam_instance_profile.this.role == aws_iam_role.this.name
    error_message = "Instance profile should reference IAM role by name"
  }

  assert {
    condition     = aws_instance.this.iam_instance_profile == aws_iam_instance_profile.this.name
    error_message = "Instance should use the module's instance profile"
  }
}

run "eip_attached" {
  command = apply

  assert {
    condition     = aws_eip.lb.instance == aws_instance.this.id
    error_message = "EIP should be attached to the bastion instance"
  }

  assert {
    condition     = aws_eip.lb.domain == "vpc"
    error_message = "EIP domain should be vpc"
  }
}

run "ami_override_used_when_set" {
  command = plan
  variables {
    ami_id = "ami-0123456789abcdef0"
  }

  assert {
    condition     = aws_instance.this.ami == "ami-0123456789abcdef0"
    error_message = "When ami_id is set, the instance should launch from that AMI rather than the data source"
  }
}

run "synapse_standard_tags" {
  command = plan

  assert {
    condition = alltrue([
      aws_security_group.this.tags["Environment"] == var.environment,
      aws_security_group.this.tags["ProvisionedBy"] == "terraform",
      aws_security_group.this.tags["Module"] == "terraform-aws-bastion-server",
      aws_security_group.this.tags["ModuleVersion"] == "local",
    ])
    error_message = "Security group must apply Synapse standard tags"
  }

  assert {
    condition = alltrue([
      aws_instance.this.tags["Environment"] == var.environment,
      aws_instance.this.tags["ProvisionedBy"] == "terraform",
      aws_instance.this.tags["Module"] == "terraform-aws-bastion-server",
      aws_instance.this.tags["ModuleVersion"] == "local",
    ])
    error_message = "EC2 instance must apply Synapse standard tags"
  }

  assert {
    condition = alltrue([
      aws_iam_role.this.tags["Environment"] == var.environment,
      aws_iam_role.this.tags["ProvisionedBy"] == "terraform",
      aws_iam_role.this.tags["Module"] == "terraform-aws-bastion-server",
      aws_iam_role.this.tags["ModuleVersion"] == "local",
    ])
    error_message = "IAM role must apply Synapse standard tags"
  }

  assert {
    condition = alltrue([
      aws_secretsmanager_secret.this.tags["Environment"] == var.environment,
      aws_secretsmanager_secret.this.tags["ProvisionedBy"] == "terraform",
      aws_secretsmanager_secret.this.tags["Module"] == "terraform-aws-bastion-server",
      aws_secretsmanager_secret.this.tags["ModuleVersion"] == "local",
    ])
    error_message = "Secrets Manager secret must apply Synapse standard tags"
  }
}
