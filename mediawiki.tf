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

resource "aws_instance" "mediawiki" {
  ami           = "ami-01ca03df4a6012157"
  instance_type = "t2.micro"
  tags = {
    Name = "Mediawiki"
  }
}
