variable "project" {
  description = "The project name"
  default = "test"
}

variable "cidr" {
  description = "The CIDR block for the VPC"
  default = "10.0.0.0/16"
}

variable "subnet_cidr" {
  description = "The CIDR block for the subnet"
  default = "10.0.1.0/24"
}

variable "availability_zone" {
  description = "The CIDR block for the subnet"
  default = "us-east-2a"
}
