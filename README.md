# AWS Bastion Server

Reusable Terraform module for a minimal SSH jump host — an EC2 instance in a public subnet, intended purely as a network hop into private resources (RDS, private-subnet services, etc.).

The module is opinionated on security posture: SSH ingress is restricted by caller-supplied CIDR (no public-internet default), IMDSv2 is required, the root volume is encrypted, and the instance is granted the SSM Session Manager managed policy as a break-glass fallback.

## Usage

```hcl
module "bastion" {
  source  = "git::https://github.com/synapsestudios/terraform-aws-bastion-server.git?ref=v4.0.0"

  namespace   = "prod-myapp"
  environment = "prod"
  vpc_id      = module.vpc.vpc_id
  subnet_id   = module.vpc.public_subnets[0]

  # Required — module does not default to 0.0.0.0/0.
  allowed_cidr_blocks = ["203.0.113.42/32"]

  # Optional — pin AMI to avoid plan-time replacement every time
  # Amazon publishes a new AL2023 image. When omitted the module resolves
  # the latest AL2023 via a data source.
  ami_id = "ami-0123456789abcdef0"

  tags = { ApplicationName = "myapp" }
}

# Cross-resource rules (e.g. letting the bastion reach a database SG) are
# the composing root module's responsibility. Reference `module.bastion.security_group_id`
# and attach them where both sides of the relationship are visible.
resource "aws_security_group_rule" "bastion_to_db" {
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  source_security_group_id = module.bastion.security_group_id
  security_group_id        = module.aurora.security_group_id
  description              = "PostgreSQL access from bastion"
}
```

## Connecting

Retrieve the SSH key from Secrets Manager, then either SSH directly or open a tunnel:

```bash
aws secretsmanager get-secret-value \
  --secret-id "$(terraform output -raw ssh_key_name)" \
  --query SecretString --output text > ~/.ssh/bastion.pem
chmod 600 ~/.ssh/bastion.pem

# Tunnel for a Postgres client talking to a private-subnet Aurora cluster:
ssh -i ~/.ssh/bastion.pem \
    -L 5432:<aurora-endpoint>:5432 \
    ec2-user@$(terraform output -raw public_ip)
```

For emergency access when the SSH key is unavailable, the instance is enrolled in SSM Session Manager — `aws ssm start-session --target <instance-id>` works without opening port 22.

## Running tests

Tests follow the [Synapse Terraform Testing guide](https://docs.synapsestudios.com/implementation/infrastructure/terraform-testing) and use the native `terraform test` framework. The `-test-directory` flag is required on `init` so Terraform discovers modules referenced from test files in non-default directories.

| Lane | Path | Cost | When it runs |
|---|---|---|---|
| Unit | `tests/unit/` | Free — `mock_provider` | On every PR |
| Integration | `tests/integration/` | Real AWS | Manual dispatch only |

Per the Synapse doc, E2E and Environment-E2E levels apply to root-module repos (deployable configs composing multiple modules); this repo is a single reusable module, so it has no E2E lane. The integration lane covers the full real-AWS path including SSH reachability.

```bash
# Unit — no AWS credentials required
terraform init -test-directory=tests/unit
terraform test -test-directory=tests/unit

# Integration — requires AWS credentials
terraform init -test-directory=tests/integration
terraform test -test-directory=tests/integration
```

The shared `tests/setup/` helper module provisions a minimal VPC + public subnet consumed by the integration lane via `run` block composition. The `tests/integration/ssh-check/` helper module wraps the `null_resource` + `remote-exec` SSH reachability probe.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.6 |
| aws | ~> 5.0 |
| null | ~> 3.0 |
| tls | ~> 4.0 |

## Providers

| Name | Version |
|------|---------|
| aws | ~> 5.0 |
| tls | ~> 4.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| allowed\_cidr\_blocks | CIDR blocks permitted to reach the bastion on port 22. | `list(string)` | n/a | yes |
| environment | Deployment environment tag value (e.g. dev, uat, prod, shared). Applied to every resource created by this module. | `string` | n/a | yes |
| namespace | Determines naming convention of assets. Generally follows DNS naming convention. | `string` | n/a | yes |
| subnet\_id | ID of subnet to deploy bastion server on. | `string` | n/a | yes |
| tags | A mapping of tags to assign to the AWS resources. | `map(string)` | n/a | yes |
| vpc\_id | ID of the VPC to deploy bastion server on. | `string` | n/a | yes |
| ami\_id | (Optional) Explicit AMI ID to launch the bastion with. When null, the latest Amazon Linux 2023 AMI is used. | `string` | `null` | no |
| instance\_type | (Optional) EC2 Instance type to provision. | `string` | `"t3.micro"` | no |
| volume\_size | (Optional) The size of the volume in gibibytes. | `number` | `30` | no |
| volume\_type | (Optional) The type of volume. Can be 'standard', 'gp2', 'gp3', 'io1', 'sc1', or 'st1'. | `string` | `"gp3"` | no |

## Outputs

| Name | Description |
|------|-------------|
| instance\_id | EC2 instance ID of the bastion server |
| public\_ip | The public IP address associated with this Bastion server |
| security\_group\_id | Security group ID of the bastion |
| ssh\_key\_name | The name of the Secrets Manager secret containing the bastion's SSH private key |
| ssh\_key\_secret\_arn | ARN of the Secrets Manager secret containing the bastion's SSH private key |
| ssh\_private\_key\_pem | The bastion's SSH private key in PEM format. Sensitive. |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
