variable "ami" {
  type        = string
  description = "AMI name of the bastion image to use."
}

variable "hostname" {
  type        = string
  description = "Hostname of the bastion server."
  default     = "bastion"
}

variable "public_ssh_key" {
  type        = string
  description = "Public SSH key to use with bastion server."
}

variable "vpc_id" {
  type        = string
  description = "ID of the VPC to deploy bastion server on."
}

variable "subnet_id" {
  type        = string
  description = "ID of subnet to deploy bastion server on."
}

variable "dns_zone" {
  type        = string
  description = "Name of the DNS zone to use with this deployment."
  default     = null
}

variable "allow_cidr" {
  type        = list(string)
  description = "List of CIDR blocks allow to connect to bastion server."
}

variable "database_security_group" {
  type        = string
  description = "ID of the security group attached to the database."
  default     = null
}

variable "database_ports" {
  type        = list(object({ port = number, description = string }))
  description = "List of TCP Port numbers to access databases."
  default     = [{ port = 5432, description = "PostgreSQL Access From Bastion" }]
}

variable "redis_security_group" {
  type        = string
  description = "ID of the security group attached to Reids / Elasticache."
  default     = null
}

variable "redis_port" {
  type        = number
  description = "TCP Port number of the Redis instance / Elasticache endpoint."
  default     = 6379
}

variable "elasticsearch_security_group" {
  type        = string
  description = "ID of the security group attached to ElasticSearch."
  default     = null
}

variable "elasticsearch_ports" {
  type        = list(number)
  description = "TCP Port numbers of the ElasticSearch endpoint."
  default     = [80, 443]
}

variable "kibana_port" {
  type        = number
  description = "TCP Port number of the ElasticSearch endpoint."
  default     = 443
}

variable "namespace" {
  type        = string
  description = "Determines naming convention of assets. Generally follows DNS naming convention."
}

variable "use_external_dns" {
  type        = bool
  description = "If true, this module will not create any Route53 DNS records."
  default     = false
}

variable "instance_type" {
  type        = string
  description = "EC2 Instance type to provision."
  default     = "t2.micro"
}

variable "iam_instance_profile" {
  type        = string
  description = " (Optional) The IAM Instance Profile to use with bastion server."
  default     = null
}

variable "tags" {
  type        = map(string)
  description = "A mapping of tags to assign to the AWS resources."
}

# Root Block Device
variable "encrypted" {
  type        = bool
  description = "(Optional) Enable volume encryption."
  default     = false
}

variable "volume_type" {
  type        = string
  description = "(Optional) The type of volume. Can be 'standard', 'gp2', 'io1', 'sc1', or 'st1'. (Default: 'gp2')."
  default     = "gp2"
}

variable "volume_size" {
  type        = number
  description = "(Optional) The size of the volume in gibibytes (Default 10 GiB)."
  default     = 10
}
