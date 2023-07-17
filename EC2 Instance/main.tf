terraform {
  required_providers {
      aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
}

variable "env_prefix"{

}

variable "my_public_key" {
  
}
variable "vpc_cidr_block" {
  
}
variable "subnet_cidr_blocks" {
}

variable "avail_zone" {}
variable "instance_type" {  
}
resource "aws_vpc" "myapp-vpc" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name = "${var.env_prefix}-vpc"
  }
}

resource "aws_subnet" "my-app-subnet-1" {
  vpc_id = aws_vpc.myapp-vpc.id
  cidr_block = var.subnet_cidr_blocks
  availability_zone = var.avail_zone
  tags = {
    Name = "${var.env_prefix}-subnet-1"
  }

}

## Route Table and Internet Gateway
resource "aws_internet_gateway" "my-app-gw" {
  vpc_id = aws_vpc.myapp-vpc.id
  tags = {
    Name ="${var.env_prefix}-gw" 
  }
}

resource "aws_route_table" "my-app-route" {
  vpc_id=aws_vpc.myapp-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my-app-gw.id
  }
  tags={
    Name="${var.env_prefix}-rtb"
  }
}

## associate route table with our subnet
resource "aws_route_table_association" "a-rtb-subnet" {
  subnet_id = aws_subnet.my-app-subnet-1.id
  route_table_id = aws_route_table.my-app-route.id

}

# Security Group and Firewall for EC2 instance
#open port22 for ssh and port 8080 for nginx

resource "aws_security_group" "my-app-sg" {
  name="myapp-sg"
  description = "Allow ssh and nginx"
  vpc_id = aws_vpc.myapp-vpc.id
  
  ingress  {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = [aws_vpc.myapp-vpc.id]
  }
  ingress{
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks =["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    prefix_list_ids = []
  }
  tags = {
    Name="${var.env_prefix}-sg"
  }
}

# AWS EC2 instance
data "aws_ami" "linux" {
  most_recent = true
  owners = [ "amazon" ]
}
resource "aws_key_pair" "deployer" {
  key_name = "deployer-key"
  public_key = var.my_public_key
}

#ssh into this instance
# ssh -i ~/.ssh/id_rsa <ip_address>
resource "aws_instance" "myapp-server" {
  ami = data.aws_ami.linux
  instance_type = var.instance_type
  subnet_id = aws_subnet.my-app-subnet-1.id
  vpc_security_group_ids = [aws_security_group.my-app-sg.id]
  availability_zone = var.avail_zone
  associate_public_ip_address = true
  key_name = aws_key_pair.deployer
  tags={
    Name="${var.env_prefix}-servers"
  }
}