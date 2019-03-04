variable "environment" {
  default = "01-network"
}

# VPC
resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"

  tags {
    Name = "${var.environment}-vpc"
  }
}

# Subnet
resource "aws_subnet" "public-a" {
  vpc_id = "${aws_vpc.vpc.id}"
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-2a"

  tags {
    Name = "${var.environment}-public-a"
  }
}

resource "aws_subnet" "private-b" {
  vpc_id = "${aws_vpc.vpc.id}"
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-2b"

  tags {
    Name = "${var.environment}-private-b"
  }
}

## public-a routing
# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.vpc.id}"

  tags {
    Name = "${var.environment}-igw"
  }
}

# VPC Route Table
resource "aws_route_table" "public_route" {
  vpc_id = "${aws_vpc.vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.igw.id}"
  }

  tags {
    Name = "${var.environment}-public_route"
  }
}

resource "aws_route_table_association" "public-a" {
  subnet_id = "${aws_subnet.public-a.id}"
  route_table_id = "${aws_route_table.public_route.id}"
}

## private-b routing
# EIP
resource "aws_eip" "eip-nat" {
  vpc = true

  lifecycle {
    create_before_destroy = true
  }

  tags {
    Name = "${var.environment}-eip-nat"
  }
}

# Nat Gateway
resource "aws_nat_gateway" "nat" {
  allocation_id = "${aws_eip.eip-nat.id}"
  subnet_id = "${aws_subnet.public-a.id}"


  lifecycle {
    create_before_destroy = true
  }

  tags{
    Name = "${var.environment}-nat"
  }
}

# VPC Route Table
resource "aws_route_table" "private_route" {
  vpc_id = "${aws_vpc.vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_nat_gateway.nat.id}"
  }

  tags {
    Name = "${var.environment}-private_route"
  }
}

resource "aws_route_table_association" "private-b" {
  subnet_id = "${aws_subnet.private-b.id}"
  route_table_id = "${aws_route_table.private_route.id}"
}

# Security Group
resource "aws_security_group" "ssh" {
  name = "ssh"
  description = "All SSH inbound traffic"
  vpc_id = "${aws_vpc.vpc.id}"
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
