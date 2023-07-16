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

variable "vpc_cidr_block" {
  
}
variable "subnet_cidr_blocks" {
}

variable "avail_zone" {}

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