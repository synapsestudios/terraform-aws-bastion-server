terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.20.1"
    }
  }
}

provider "aws" {
  region = "us-west-2"
}

locals {
  vpc_cidr  = "10.100.32.0/20"
  namespace = var.namespace
  tags = {
    managed_by  = "terraform"
    environment = "test"
  }
}

#####################
# ECS - VPC & Subnets
#####################
module "vpc" {
  source                     = "terraform-aws-modules/vpc/aws"
  version                    = "3.0.0"
  name                       = local.namespace
  cidr                       = local.vpc_cidr
  azs                        = ["us-west-2a", "us-west-2b", "us-west-2c"]
  private_subnets            = [cidrsubnet(local.vpc_cidr, 4, 0)]
  public_subnets             = [cidrsubnet(local.vpc_cidr, 4, 1)]
  enable_dns_hostnames       = true
  enable_dns_support         = true
  single_nat_gateway         = true
  enable_nat_gateway         = true
  manage_default_route_table = true
  public_subnet_tags         = { "immutable_metadata" = "{\"purpose\":\"${local.namespace}-public\"}" }
  private_subnet_tags        = { "immutable_metadata" = "{\"purpose\":\"${local.namespace}-private\"}" }
  tags = {
    managed_by = "terraform"
    namespace  = local.namespace
  }
}

resource "aws_security_group" "https" {
  name   = "${local.namespace}-https"
  vpc_id = module.vpc.vpc_id
  egress {
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

module "bastion_host" {
  source    = "../../"
  tags      = merge(local.tags, { Name = "Bastion" })
  namespace = local.namespace
  subnet_id = module.vpc.public_subnets[0]
  vpc_id    = module.vpc.vpc_id
}

# Output the instance's public IP address.
output "public_ip" {
  value = module.bastion_host.public_ip
}

# Output the secret name for the ssh key
output "ssh_key_name" {
  value = module.bastion_host.ssh_key_name
}
