output "vpc_id" {
  description = "The ID of the VPC"
  value       = "${module.vpc.vpc_id}"
}

output "subnet_id" {
  description = "The ID of the Public A Subnet"
  value       = "${module.vpc.public_subnets}"
}