terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  profile = "default"
  region  = "us-east-1"
}

resource "aws_key_pair" "saurabh-labpc" {
  key_name   = "saurabh-labpc"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAxvplzAxWC3DfOnbb7EMZCEOKiI5ALDLVFT56czeyKAO6MY5D1E79f74t1HmIHwpoAOekXdnu580zC7Ni5Wynk6M4YnPfHF2cs4hhMBFttxUWsrI3Cqfyb8zsjyddXKg0XbPj/BvlqA8SBHQX7DGd4gXTXJXHeySvu5y8Rd0f9mpzHYk9+lW06Q3uyON9jzL/PeRD8h8uHb1vqi6+V5R0ShHc1ptlDH90DKd3pgm/cer7WJHNlqsQybAf0ypcfqzDPtywgccTFgnfwnltb3WYCbXcMmrjLCXXrQ8qZMTkZzpnPVT3/FfmaaN9OCvG266kPU/O2s3zxeaaHRWq2aESIQ== saurabh@labpc"
}

resource "aws_instance" "mediawiki" {
  ami           = "ami-01ca03df4a6012157"
  instance_type = "t2.micro"
  key_name = aws_key_pair.saurabh-labpc.key_name
  tags = {
    Name = "Mediawiki"
  }
  depends_on = [aws_instance.mariadb]
}

resource "aws_eip" "mediawiki-ip" {
    vpc = true
    instance = aws_instance.mediawiki.id
    tags = {
      Name = "Mediawiki-EIP"
    }
}

resource "aws_instance" "mariadb" {
  ami           = "ami-01ca03df4a6012157"
  instance_type = "t2.micro"
  key_name = aws_key_pair.saurabh-labpc.key_name
  tags = {
    Name = "Mariadb"
  }
}

