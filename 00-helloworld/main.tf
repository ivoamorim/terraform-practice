variable "access_key" {}
variable "secret_key" {}
variable "region" {
  default = "us-east-2"
}

provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region = "${var.region}"
}

resource "aws_vpc" "vpc-test" {
  cidr_block = "10.0.0.0/16"

  tags {
    Name = "vpc-test"
  }
}

resource "aws_subnet" "public-a" {
  vpc_id = "${aws_vpc.vpc-test.id}"
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-2a"

  tags {
    Name = "public-a"
  }
}

resource "aws_internet_gateway" "igw-test" {
  vpc_id = "${aws_vpc.vpc-test.id}"

  tags {
    Name = "igw-test"
  }
}

resource "aws_route_table" "public_route" {
  vpc_id = "${aws_vpc.vpc-test.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.igw-test.id}"
  }

  tags {
    Name = "public_route"
  }
}

resource "aws_route_table_association" "public-a" {
  subnet_id = "${aws_subnet.public-a.id}"
  route_table_id = "${aws_route_table.public_route.id}"
}

resource "aws_security_group" "ssh" {
  name = "ssh"
  description = "All SSH inbound traffic"
  vpc_id = "${aws_vpc.vpc-test.id}"
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "SSH"
  }
}

resource "aws_instance" "ec2-test" {
  ami = "ami-07413a099547ecc89"
  instance_type = "t2.micro"
  key_name = "foo-key"
  vpc_security_group_ids = [
    "${aws_security_group.ssh.id}"
  ]

  subnet_id = "${aws_subnet.public-a.id}"
  associate_public_ip_address = "true"
  root_block_device = {
    volume_type = "gp2"
    volume_size = "20"
  }

  ebs_block_device = {
    device_name = "/dev/sdf"
    volume_type = "gp2"
    volume_size = "100"
  }

  tags {
    Name = "ec2-test"
  }
}