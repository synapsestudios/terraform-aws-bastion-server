output "public_ip" {
  description = "The public IP address associated with this Bastion server"
  value       = aws_eip.lb.public_ip
}

output "instance_id" {
  description = "EC2 instance ID of the bastion server"
  value       = aws_instance.this.id
}

output "security_group_id" {
  description = "Security group ID of the bastion. Consumers that need to permit traffic from the bastion to another resource (e.g. a database) should reference this and create the target-side ingress rule in their own root module, keeping cross-resource rule ownership out of this module."
  value       = aws_security_group.this.id
}

output "ssh_key_name" {
  description = "The name of the Secrets Manager secret containing the bastion's SSH private key"
  value       = aws_secretsmanager_secret.this.name
}

output "ssh_key_secret_arn" {
  description = "ARN of the Secrets Manager secret containing the bastion's SSH private key"
  value       = aws_secretsmanager_secret.this.arn
}

output "ssh_private_key_pem" {
  description = "The bastion's SSH private key in PEM format. Sensitive."
  value       = tls_private_key.key.private_key_pem
  sensitive   = true
}
