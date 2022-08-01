output "public_ip" {
  description = "The public IP address associated with this Bastion server"
  value       = aws_eip.lb.public_ip
}

# Output the secret name for the ssh key
output "ssh_key_name" {
  description = "The name of the Secrets Manager key for the bastion server's ssh key"
  value       = aws_secretsmanager_secret.this.name
}
