variable "environment" {
  default = "02-compute"
}

# AMI
data "aws_ami" "debian9" {
  most_recent = true
  owners = ["379101102735"]

  filter {
    name = "name"
    values = ["debian-stretch-hvm-x86_64-gp2*"]
  }
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

resource "aws_security_group" "http" {
  name = "http"
  description = "All HTTP inbound traffic"
  vpc_id = "${aws_vpc.vpc.id}"
  ingress {
    from_port = 80
    to_port = 80
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
    Name = "HTTP"
  }
}

resource "aws_security_group" "https" {
  name = "https"
  description = "All HTTPS inbound traffic"
  vpc_id = "${aws_vpc.vpc.id}"
  ingress {
    from_port = 443
    to_port = 443
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
    Name = "HTTPS"
  }
}

# EC2 Instance
resource "aws_launch_configuration" "web" {
  name = "${var.environment}-web-launch_configuration"
  image_id = "${data.aws_ami.debian9.id}"
  instance_type = "t2.micro"
  security_groups = [
    "${aws_security_group.ssh.id}",
    "${aws_security_group.http.id}",
    "${aws_security_group.https.id}",
  ]

  root_block_device = {
    volume_type = "gp2"
    volume_size = "20"
  }

  lifecycle {
    ignore_changes = ["ami"]
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "web" {
  name = "${var.environment}-web-autoscaling_group"
  min_size = 2
  max_size = 2
  launch_configuration = "${aws_launch_configuration.web.id}"
  vpc_zone_identifier = [
    "${aws_subnet.public-a.id}",
  ]

  tags {
    key = "Name"
    value = "${var.environment}-web-autoscaling_group"
    propagate_at_launch = true
  }
}

resource "aws_instance" "db" {
  count = 1

  ami = "${data.aws_ami.debian9.id}"
  instance_type = "t2.micro"
  disable_api_termination = true
  vpc_security_group_ids = [
    "${aws_security_group.ssh.id}",
  ]
  subnet_id = "${aws_subnet.private-b.id}"

  root_block_device = {
    volume_type = "gp2"
    volume_size = "20"
  }

  lifecycle {
    ignore_changes = ["ami"]
    create_before_destroy = true
  }

  tags = {
    Name = "${var.environment}-${format("db%02d", count.index + 1)}"
  }
}