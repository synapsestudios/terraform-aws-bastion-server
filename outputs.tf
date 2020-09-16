output "public_ip" {
  description = "The public IP address associated with this Bastion server"
  value       = aws_instance.this.public_ip
}

output "security_group_id" {
  description = "Bastion server's AWS Security Group ID."
  value       = aws_security_group.this.id
}

output "id" {
  description = "Bastion server's Instance ID."
  value       = aws_instance.this.id
}
