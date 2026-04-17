output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnet_id" {
  value = module.vpc.public_subnets[0]
}

output "runner_ingress_cidr" {
  description = "The test runner's public IP as a /32 CIDR, suitable for scoping SSH ingress on the bastion under test."
  value       = "${trimspace(data.http.runner_ip.response_body)}/32"
}
