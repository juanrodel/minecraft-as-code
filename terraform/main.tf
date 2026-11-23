terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}

# Automatically fetch the latest official Canonical Ubuntu 26.04 LTS AMI
data "aws_ami" "ubuntu_26_04" {
  most_recent = true
  owners      = ["099720109477"] # Canonical's official AWS Account ID

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-26.04-amd64-server-*", "ubuntu/images/hvm-ssd-gp3/ubuntu-*-26.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_key_pair" "deployer" {
  key_name   = "mc-deployer-key"
  public_key = var.ssh_public_key
}

resource "aws_security_group" "mc_sg" {
  name        = "minecraft-game-host-sg"
  description = "Allow Minecraft Java and SSH traffic"

  ingress {
    from_port   = 25565
    to_port     = 25565
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "game_host" {
  ami                    = data.aws_ami.ubuntu_26_04.id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.deployer.key_name
  vpc_security_group_ids = [aws_security_group.mc_sg.id]

  tags = {
    Name = "minecraft-game-host"
  }
}

resource "aws_instance" "status_vm" {
  ami           = data.aws_ami.ubuntu_26_04.id
  instance_type = "t3.micro"
  key_name      = aws_key_pair.deployer.key_name

  tags = {
    Name = "minecraft-status-vm"
  }
}