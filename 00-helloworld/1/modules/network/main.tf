resource "aws_vpc" "vpc" {
  cidr_block = "${var.cidr}"

  tags {
    Name = "VPC ${var.project}"
    Terraform = "true"
  }
}

resource "aws_subnet" "public_a" {
  vpc_id = "${aws_vpc.vpc.id}"
  cidr_block = "${var.subnet_cidr}"
  availability_zone = "${var.availability_zone}"

  tags {
    Name = "${var.project} Public A"
    Terraform = "true"
  }
}


resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.vpc.id}"

  tags {
    Name = "${var.project} IGW"
    Terraform = "true"
  }
}

resource "aws_route_table" "public_route" {
  vpc_id = "${aws_vpc.vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.igw.id}"
  }

  tags {
    Name = "${var.project} Public Route Table"
    Terraform = "true"
  }
}
