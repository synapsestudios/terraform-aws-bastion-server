# AWS Bastion Server

This module creates an AWS EC2 Instance with a given AMI to be used as a bastion server. Multiple inputs are available to allow access to existing security groups as well as restricting SSH access by network CIDR.

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

# Integration — requires AWS credentials (AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, AWS_DEFAULT_REGION)
# Provisions real infra, asserts on shape/state, SSHes to the bastion, and tears everything down.
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
| namespace | Determines naming convention of assets. Generally follows DNS naming convention. | `string` | n/a | yes |
| environment | Deployment environment tag value (e.g. dev, uat, prod, shared). Applied to every resource created by this module. | `string` | n/a | yes |
| subnet\_id | ID of subnet to deploy bastion server on. | `string` | n/a | yes |
| tags | A mapping of tags to assign to the AWS resources. | `map(string)` | n/a | yes |
| vpc\_id | ID of the VPC to deploy bastion server on. | `string` | n/a | yes |
| instance\_type | (Optional) EC2 Instance type to provision. | `string` | `"t3.micro"` | no |
| volume\_size | (Optional) The size of the volume in gibibytes (Default 15 GiB). | `number` | `15` | no |
| volume\_type | (Optional) The type of volume. Can be 'standard', 'gp2', 'io1', 'sc1', or 'st1'. (Default: 'gp2'). | `string` | `"gp2"` | no |

## Outputs

| Name | Description |
|------|-------------|
| public\_ip | The public IP address associated with this Bastion server |
| ssh\_key\_name | The name of the Secrets Manager key for the bastion server's ssh key |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
