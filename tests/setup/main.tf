terraform {
  required_providers {
    aws  = { source = "hashicorp/aws", version = "~> 5.0" }
    http = { source = "hashicorp/http", version = "~> 3.0" }
  }
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = var.namespace
  cidr = "10.100.32.0/20"

  azs             = ["us-west-2a"]
  public_subnets  = ["10.100.32.0/24"]
  private_subnets = ["10.100.33.0/24"]

  enable_nat_gateway   = false
  enable_dns_hostnames = true
  enable_dns_support   = true
}

# Discover the test runner's egress IP so the integration lane can scope SSH
# ingress to that single /32 instead of punching 0.0.0.0/0 into the SG.
data "http" "runner_ip" {
  url = "https://checkip.amazonaws.com/"
}
