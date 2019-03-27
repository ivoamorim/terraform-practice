
variable "access_key" {}
variable "secret_key" {}
variable "region" {
  default = "us-east-2"
}

variable "project" {
  description = "The project name"
  default     = "test"
}