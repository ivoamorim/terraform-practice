module "ec2" {
  source                 = "terraform-aws-modules/ec2-instance/aws"
  version                = "1.12.0"

  name                   = "${var.project} instance"
  instance_count         = 1

  ami                    = "ami-04328208f4f0cf1fe"
  instance_type          = "t2.micro"
  key_name               = "test"
  monitoring             = false
  vpc_security_group_ids = ["sg-12345678"]
  subnet_id              = "subnet-eddcdzz4"

  tags = {
    Environment = "${var.environment}"
    Terraform = "true"
  }
}

module "ssh_common_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "web-server"
  description = "Security group for ssh with HTTP ports open within VPC"
  vpc_id      = "${var.vpc_id}"

  ingress_cidr_blocks = ["0.0.0.0/0"]
}