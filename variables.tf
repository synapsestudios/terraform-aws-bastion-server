variable "volume_size" {
  type        = number
  description = "(Optional) The size of the volume in gibibytes."
  default     = 30
}

variable "volume_type" {
  type        = string
  description = "(Optional) The type of volume. Can be 'standard', 'gp2', 'gp3', 'io1', 'sc1', or 'st1'."
  default     = "gp3"
}

variable "vpc_id" {
  type        = string
  description = "ID of the VPC to deploy bastion server on."
}

variable "subnet_id" {
  type        = string
  description = "ID of subnet to deploy bastion server on."
}

variable "namespace" {
  type        = string
  description = "Determines naming convention of assets. Generally follows DNS naming convention."
}

variable "environment" {
  type        = string
  description = "Deployment environment tag value (e.g. dev, uat, prod, shared). Applied to every resource created by this module."
}

variable "instance_type" {
  type        = string
  description = "(Optional) EC2 Instance type to provision."
  default     = "t3.micro"
}

variable "tags" {
  type        = map(string)
  description = "A mapping of tags to assign to the AWS resources."
}

variable "allowed_cidr_blocks" {
  type        = list(string)
  description = "CIDR blocks permitted to reach the bastion on port 22. The module intentionally requires this — prior versions defaulted to 0.0.0.0/0, which defeats the purpose of a jump host. Production callers should restrict to known egress IPs (office, VPN, NAT gateway, etc.). An empty list denies all SSH ingress."
}

variable "ami_id" {
  type        = string
  description = "(Optional) Explicit AMI ID to launch the bastion with. When null, the latest Amazon Linux 2023 AMI is used via a data source — convenient but means every new AMI Amazon publishes forces a plan-time replacement. Production callers should pin a specific AMI ID and bump it on their own cadence."
  default     = null
}
