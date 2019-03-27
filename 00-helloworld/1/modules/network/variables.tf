variable "project" {
  description = "The project name"
  default = "test"
}

variable "cidr" {
  description = "The CIDR block for the VPC"
  default = "10.0.0.0/16"
}