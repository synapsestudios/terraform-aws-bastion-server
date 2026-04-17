variable "host" {
  type        = string
  description = "Public IP or hostname of the bastion to SSH into."
}

variable "secret_name" {
  type        = string
  description = "Name of the Secrets Manager secret holding the bastion's SSH private key."
}
