terraform {
    required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "5.65.0"
    }

    github = {
        source = "integrations/github"
        version = "6.2.3"
    }
    }
}

provider "aws" {
    region = "us-east-1"
}

resource "aws_security_group" "brc-sg" {
    name = "${terraform.workspace}-sg"
    tags = {
        Name = "${terraform.workspace}-sg"
    }

    ingress {
        from_port = 22
        protocol = "tcp"
        to_port = 22
        cidr_blocks = [ "0.0.0.0/0" ]
    }

    egress {
        from_port = 0
        protocol = -1
        to_port = 0
        cidr_blocks = [ "0.0.0.0/0" ]
    }
}

variable "ins_ami" {
  default = default
}

variable "ins_type" {
  default = default
}


variable "volume_size" {
  default = default
}


variable "keypair" {
  default = default
}


resource "aws_instance" "tfmyec2" {
  ami = lookup(var.ins_ami, terraform.workspace)
  instance_type = var.ins_type[terraform.workspace]  #lookup haricinde bu sekilde de kullanilabilir, ornek olmasi icin yaptim
  key_name = var.keypair[terraform.workspace]
  security_groups = [aws_security_group.brc-sg.name]
  root_block_device {
    volume_size = lookup(var.volume_size, terraform.workspace)
  }

  tags = {
    Name = "${terraform.workspace}-server"

  }
}

output "workspace_instance_ip" {
  description = "Public IP"
  value       = "${terraform.workspace}-instance ip: ${aws_instance.tfmyec2.public_ip}"
}