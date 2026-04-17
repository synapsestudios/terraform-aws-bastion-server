data "aws_ami" "amazon_linux_2023" {
  count       = var.ami_id == null ? 1 : 0
  owners      = ["amazon"]
  most_recent = true

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

locals {
  default_tags = {
    Environment   = var.environment
    ProvisionedBy = "terraform"
    Module        = "terraform-aws-bastion-server"
    ModuleVersion = "local"
  }

  ami_id = var.ami_id != null ? var.ami_id : data.aws_ami.amazon_linux_2023[0].id
}

resource "tls_private_key" "key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "this" {
  key_name_prefix = var.namespace
  public_key      = tls_private_key.key.public_key_openssh
}

resource "aws_secretsmanager_secret" "this" {
  name_prefix = var.namespace
  description = "bastion private key"
  tags        = merge(local.default_tags, var.tags)
}

resource "aws_secretsmanager_secret_version" "this" {
  secret_id     = aws_secretsmanager_secret.this.id
  secret_string = tls_private_key.key.private_key_pem
}

resource "aws_instance" "this" {
  ami                         = local.ami_id
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.this.name
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.this.key_name
  subnet_id                   = var.subnet_id
  tags                        = merge(local.default_tags, var.tags)
  vpc_security_group_ids      = [aws_security_group.this.id]

  root_block_device {
    encrypted   = true
    volume_type = var.volume_type
    volume_size = var.volume_size
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
    instance_metadata_tags      = "enabled"
  }
}

resource "aws_eip" "lb" {
  instance = aws_instance.this.id
  domain   = "vpc"
}

resource "aws_security_group" "this" {
  description = "Bastion"
  vpc_id      = var.vpc_id
  name        = "bastion-${var.namespace}"
  tags        = merge(local.default_tags, var.tags, { Name = "Bastion" })

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = 6
    cidr_blocks = var.allowed_cidr_blocks
    description = "Allow SSH from authorized CIDRs."
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow outgoing traffic."
  }
}

resource "aws_iam_role" "this" {
  name = "${var.namespace}Role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  tags = merge(local.default_tags, var.tags)
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.this.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "this" {
  name = aws_iam_role.this.name
  role = aws_iam_role.this.name
}
