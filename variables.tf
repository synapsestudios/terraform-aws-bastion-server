variable "hostname" {
  type        = string
  description = "Hostname of the bastion server."
  default     = "bastion"
}

variable "volume_size" {
  type        = number
  description = "(Optional) The size of the volume in gibibytes (Default 15 GiB)."
  default     = 15
}

variable "volume_type" {
  type        = string
  description = "(Optional) The type of volume. Can be 'standard', 'gp2', 'io1', 'sc1', or 'st1'. (Default: 'gp2')."
  default     = "gp2"
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

variable "instance_type" {
  type        = string
  description = "(Optional) EC2 Instance type to provision."
  default     = "t3.micro"
}

variable "iam_instance_profile" {
  type        = string
  description = "(Optional) The IAM Instance Profile to use with bastion server."
  default     = null
}

variable "tags" {
  type        = map(string)
  description = "A mapping of tags to assign to the AWS resources."
}
