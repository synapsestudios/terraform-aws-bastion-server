# AWS Bastion Server

This module creates an AWS EC2 Instance with a given AMI to be used as a bastion server. Multiple inputs are available to allow access to existing security groups as well as restricting SSH access by network CIDR.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| terraform | ~> 0.12.29 |
| aws | ~> 2.53 |

## Providers

| Name | Version |
|------|---------|
| aws | ~> 2.53 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| allow\_cidr | List of CIDR blocks allow to connect to bastion server. | `list(string)` | n/a | yes |
| ami | AMI name of the bastion image to use. | `string` | n/a | yes |
| namespace | Determines naming convention of assets. Generally follows DNS naming convention. | `string` | n/a | yes |
| public\_ssh\_key | Public SSH key to use with bastion server. | `string` | n/a | yes |
| subnet\_id | ID of subnet to deploy bastion server on. | `string` | n/a | yes |
| tags | A mapping of tags to assign to the AWS resources. | `map(string)` | n/a | yes |
| vpc\_id | ID of the VPC to deploy bastion server on. | `string` | n/a | yes |
| database\_ports | List of TCP Port numbers to access databases. | `list(object({ port = number, description = string }))` | <pre>[<br>  {<br>    "description": "PostgreSQL Access From Bastion",<br>    "port": 5432<br>  }<br>]</pre> | no |
| database\_security\_group | ID of the security group attached to the database. | `string` | `null` | no |
| dns\_zone | Name of the DNS zone to use with this deployment. | `string` | `null` | no |
| elasticsearch\_ports | TCP Port numbers of the ElasticSearch endpoint. | `list(number)` | <pre>[<br>  80,<br>  443<br>]</pre> | no |
| elasticsearch\_security\_group | ID of the security group attached to ElasticSearch. | `string` | `null` | no |
| encrypted | (Optional) Enable volume encryption. | `bool` | `false` | no |
| hostname | Hostname of the bastion server. | `string` | `"bastion"` | no |
| iam\_instance\_profile | (Optional) The IAM Instance Profile to use with bastion server. | `string` | `null` | no |
| instance\_type | EC2 Instance type to provision. | `string` | `"t2.micro"` | no |
| kibana\_port | TCP Port number of the ElasticSearch endpoint. | `number` | `443` | no |
| redis\_port | TCP Port number of the Redis instance / Elasticache endpoint. | `number` | `6379` | no |
| redis\_security\_group | ID of the security group attached to Reids / Elasticache. | `string` | `null` | no |
| use\_external\_dns | If true, this module will not create any Route53 DNS records. | `bool` | `false` | no |
| volume\_size | (Optional) The size of the volume in gibibytes (Default 10 GiB). | `number` | `10` | no |
| volume\_type | (Optional) The type of volume. Can be 'standard', 'gp2', 'io1', 'sc1', or 'st1'. (Default: 'gp2'). | `string` | `"gp2"` | no |

## Outputs

| Name | Description |
|------|-------------|
| id | Bastion server's Instance ID. |
| public\_ip | The public IP address associated with this Bastion server |
| security\_group\_id | Bastion server's AWS Security Group ID. |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->