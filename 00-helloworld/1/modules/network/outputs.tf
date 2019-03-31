output "vpc_id" {
  description = "The ID of the VPC"
  value       = "${aws_vpc.vpc.id}"
}

output "subnet_id" {
  description = "The ID of the Public A Subnet"
  value       = "${aws_subnet.public_a.id}"
}
