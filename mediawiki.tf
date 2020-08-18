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

resource "aws_key_pair" "terraform" {
  key_name   = "terraform"
  public_key = file("terraform.pub")
}

resource "aws_default_vpc" "default" {
  tags = {
    Name = "Default VPC"
  }
}

resource "aws_security_group" "webserver" {
  name        = "webserver"
  description = "Allow web traffic"
  vpc_id      = aws_default_vpc.default.id

  ingress {
    description = "SSH from anywhere"
    from_port   = 0
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "HTTP from anywhere"
    from_port   = 0
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "HTTPS from anywhere"
    from_port   = 0
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Mariadb from VPC"
    from_port   = 0
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [aws_default_vpc.default.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Webserver-SG"
  }
}

resource "aws_instance" "mediawiki" {
  ami           = "ami-01ca03df4a6012157"
  instance_type = "t2.micro"
  key_name = aws_key_pair.terraform.key_name
  vpc_security_group_ids = [aws_security_group.webserver.id]
  tags = {
    Name = "Mediawiki"
  }
  connection {
    type        = "ssh"
    user        = "centos"
    private_key = file("terraform")
    host        = self.public_ip
  }
#  provisioner "local-exec" {
#    command = "echo ${aws_eip.mediawiki-ip.public_ip} > mediawiki-public-ip.txt"
#  }
  provisioner "file" {
    source      = "mysql-root-password"
    destination = "mysql-root-password"
  }
  provisioner "file" {
    source      = "setup_httpd.sh"
    destination = "setup_httpd.sh"
  }
  provisioner "remote-exec" {
    inline = [
      "chmod +x setup_httpd.sh",
      "./setup_httpd.sh ${aws_instance.mariadb.private_ip}"
    ]
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
  key_name = aws_key_pair.terraform.key_name
  vpc_security_group_ids = [aws_security_group.webserver.id]
  tags = {
    Name = "Mariadb"
  }
  connection {
    type        = "ssh"
    user        = "centos"
    private_key = file("terraform")
    host        = self.public_ip
  }
  provisioner "local-exec" {
    command = "echo ${aws_instance.mariadb.private_ip} > mariadb-private-ip.txt"
  }
  provisioner "file" {
    source      = "mysql-root-password"
    destination = "mysql-root-password"
  }
  provisioner "file" {
    source      = "setup_mariadb.sh"
    destination = "setup_mariadb.sh"
  }
  provisioner "remote-exec" {
    inline = [
      "chmod +x setup_mariadb.sh",
      "./setup_mariadb.sh"
    ]
  }
}



