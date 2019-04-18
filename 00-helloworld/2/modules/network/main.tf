module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "${var.project} VPC"
  cidr = "${var.cidr}"

  azs            = ["${var.availability_zone}"]
  public_subnets = ["${var.subnet_cidr}"]

  enable_nat_gateway = false
  enable_vpn_gateway = false

  tags = {
    Terraform = "true"
    Environment = "${var.environment}"
  }
}