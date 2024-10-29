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

variable "ins-ami" {
  type = map(string)
  default = {
    staging = "ami-06b21ccaeff8cd686"
    dev     = "ami-0ddc798b3f1a5117e"
    prod    = "ami-06b21ccaeff8cd686"
    test    = "ami-0ddc798b3f1a5117e"
  }
}

variable "ins-type" {
  type = map(string)
  default = {
    staging = "t2.nano"
    dev     = "t2.micro"
    prod    = "t2.small"
    test    = "t2.medium"
  }
}


variable "volume-size" {
  type = map(string)
  default = {
    staging = "10"
    dev     = "12"
    prod    = "14"
    test    = "16"
  }
}


variable "keypair" {
  type = map(string)
  default = {
    staging = "staging-key"
    dev     = "dev-key"
    prod    = "prod-key"
    test    = "test-key"
  }
}


resource "aws_instance" "tfmyec2" {
  ami = lookup(var.ins-ami, terraform.workspace)
  instance_type = var.ins-type[terraform.workspace]  #lookup haricinde bu sekilde de kullanilabilir, ornek olmasi icin yaptim
  key_name = var.keypair[terraform.workspace]
  security_groups = [aws_security_group.brc-sg.name]
  root_block_device {
    volume_size = lookup(var.volume-size, terraform.workspace)
  }

  tags = {
   Project = "Devops-Project-Server"
   Name = "${terraform.workspace}_server"
  }
}

output "workspace_instance_ip" {
  description = "Public IP"
  value       = "${terraform.workspace}-instance ip: ${aws_instance.tfmyec2.public_ip}"
}

output "instance_id" {
  description = "Public Id"
  value       = aws_instance.tfmyec2.id
}

