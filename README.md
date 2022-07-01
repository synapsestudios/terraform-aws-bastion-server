# AWS Bastion Server

This module creates an AWS EC2 Instance with a given AMI to be used as a bastion server. Multiple inputs are available to allow access to existing security groups as well as restricting SSH access by network CIDR.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| terraform | ~> 1.2.2 |
| aws | ~> 4.20.1 |

## Providers

| Name | Version |
|------|---------|
| aws | ~> 4.20.1 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| namespace | Determines naming convention of assets. Generally follows DNS naming convention. | `string` | n/a | yes |
| subnet\_id | ID of subnet to deploy bastion server on. | `string` | n/a | yes |
| tags | A mapping of tags to assign to the AWS resources. | `map(string)` | n/a | yes |
| vpc\_id | ID of the VPC to deploy bastion server on. | `string` | n/a | yes |
| hostname | Hostname of the bastion server. | `string` | `"bastion"` | no |
| iam\_instance\_profile | (Optional) The IAM Instance Profile to use with bastion server. | `string` | `null` | no |
| instance\_type | (Optional) EC2 Instance type to provision. | `string` | `"t3.micro"` | no |
| volume\_size | (Optional) The size of the volume in gibibytes (Default 10 GiB). | `number` | `10` | no |
| volume\_type | (Optional) The type of volume. Can be 'standard', 'gp2', 'io1', 'sc1', or 'st1'. (Default: 'gp2'). | `string` | `"gp2"` | no |

## Outputs

| Name | Description |
|------|-------------|
| public\_ip | The public IP address associated with this Bastion server |
| ssh\_key\_name | The name of the Secrets Manager key for the bastion server's ssh key |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->