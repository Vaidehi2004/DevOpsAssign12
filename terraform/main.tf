data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}

resource "tls_private_key" "tf_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "local_file" "private_key_pem" {
  content  = tls_private_key.tf_key.private_key_pem
  filename = "${path.module}/terraform-key.pem"
  file_permission = "0400"
}

resource "aws_key_pair" "deployer" {
  key_name   = "devops_assignment_key"
  public_key = tls_private_key.tf_key.public_key_openssh
}

resource "aws_security_group" "sg" {
  name        = "devops_assignment_sg"
  description = "Allow SSH, HTTP, HTTPS, Swarm ports"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Docker Swarm ports
  ingress {
    description = "Swarm manager"
    from_port   = 2377
    to_port     = 2377
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Container overlay"
    from_port   = 4789
    to_port     = 4789
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Swarm internal"
    from_port   = 7946
    to_port     = 7946
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Swarm internal UDP"
    from_port   = 7946
    to_port     = 7946
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

locals {
  base_ami_id = length(var.ami_id) > 0 ? var.ami_id : data.aws_ami.ubuntu.id
}

resource "aws_instance" "controller" {
  ami                    = local.base_ami_id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.deployer.key_name
  vpc_security_group_ids = [aws_security_group.sg.id]
  tags = { Name = "controller" }
}

resource "aws_instance" "manager" {
  ami                    = local.base_ami_id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.deployer.key_name
  vpc_security_group_ids = [aws_security_group.sg.id]
  tags = { Name = "swarm-manager" }
}

resource "aws_instance" "worker_a" {
  ami                    = local.base_ami_id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.deployer.key_name
  vpc_security_group_ids = [aws_security_group.sg.id]
  tags = { Name = "swarm-worker-a" }
}

resource "aws_instance" "worker_b" {
  ami                    = local.base_ami_id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.deployer.key_name
  vpc_security_group_ids = [aws_security_group.sg.id]
  tags = { Name = "swarm-worker-b" }
}

resource "aws_eip" "manager_eip" {
  instance = aws_instance.manager.id
  vpc      = true
}

resource "aws_eip" "worker_a_eip" {
  instance = aws_instance.worker_a.id
  vpc      = true
}

resource "aws_eip" "worker_b_eip" {
  instance = aws_instance.worker_b.id
  vpc      = true
}
