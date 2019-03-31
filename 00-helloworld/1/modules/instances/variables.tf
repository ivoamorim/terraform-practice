variable "project" {
  description = "The project name"
  default = "test"
}

variable "vpc_id" {
  description = "The VPC ID"
}

variable "subnet_id" {
  description = "The CIDR block for the VPC"
}

variable "create_eip" {
  description = "Boolean whether creating EIP for an instance"
  default = "false"
}
