resource "aws_vpc" "myapp-vpc" {
  cidr_block = var.vpc_cidr_block

  tags={
    "Name"="${var.env_prefix}-vpc"

  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.myapp-vpc.id
  tags={
    "Name"="${var.env_prefix}-igw"
  }
}

## For EKS we need two public and two private subnet
resource "aws_subnet" "private-us-west-1a" {
  vpc_id = aws_vpc.myapp-vpc.id
  cidr_block = var.subnet_cidr_blocks[0]
  availability_zone = var.avail_zone
  tags = {
    "Name"="${var.env_prefix}-private-subnet-01"
    "kubernetes.io/role/internal-elb" = "1"
    "kubernetes.io/cluster/demo" ="owned"
  }
}

resource "aws_subnet" "private-us-west-1b" {
  vpc_id = aws_vpc.myapp-vpc.id
  cidr_block = var.subnet_cidr_blocks[1]
  availability_zone = "us-west-1b"
  tags = {
   "Name"="${var.env_prefix}-private-subnet-02"
    "kubernetes.io/role/internal-elb" = "1"
    "kubernetes.io/cluster/demo"="owned"
  }
}

##public subnet
resource "aws_subnet" "public-us-west-1a" {
  vpc_id = aws_vpc.myapp-vpc.id
  cidr_block = var.subnet_cidr_blocks[2]
  availability_zone = "us-west-1a"
  map_public_ip_on_launch = true
  tags = {
    "Name"="${var.env_prefix}-public-us-west-1a"
    "kubernetes.io/role/elb" = "1"
    "kubernetes.io/cluster/demo" ="owned"
  }
}

resource "aws_subnet" "public-us-west-1b" {
  vpc_id = aws_vpc.myapp-vpc.id
  cidr_block = var.subnet_cidr_blocks[3]
  availability_zone = "us-west-1b"
  map_public_ip_on_launch = true
  tags = {
    "Name"="${var.env_prefix}-public-us-west-1b"
    "kubernetes.io/role/elb" = "1"
    "kubernetes.io/cluster/demo" ="owned"
  }
}

## Nat Gatway for private subnets, NAT gateway need an elastic IP address
resource "aws_eip" "nat" {
  vpc = true
  tags={
    "Name"="nat"
  }
}

resource "aws_nat_gateway" "nat" {
  connectivity_type = "public"
  subnet_id = aws_subnet.public-us-west-1a.id
  allocation_id = aws_eip.nat.id
  tags = {
    "Name" = "${var.env_prefix}-nat-gateway"
  }

  ## this is for proper ordeting. recommended from terraform
  depends_on = [ aws_internet_gateway.igw ]
}

## Routing goes here