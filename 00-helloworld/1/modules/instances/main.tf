resource "aws_instance" "ec2" {
  ami = "ami-04328208f4f0cf1fe"
  instance_type = "t2.micro"
  disable_api_termination = true
  subnet_id = "${var.subnet_id}"
  vpc_security_group_ids = [
    "${aws_security_group.ssh.id}",
  ]

  root_block_device = {
    volume_type = "gp2"
    volume_size = "20"
  }

  tags {
    Name = "${var.project} EC2"
    Terraform = "true"
  }
}

resource "aws_security_group" "ssh" {
  name = "ssh"
  description = "All SSH inbound traffic"
  vpc_id = "${var.vpc_id}"
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
    Terraform = "true"
  }
}

resource "aws_eip" "eip" {
  count    = "${var.create_eip == false ? 0 : 1}"
  instance = "${aws_instance.ec2.id}"
  vpc      = true

  tags {
    Name = "${var.project} EIP"
    Terraform = "true"
  }
}
