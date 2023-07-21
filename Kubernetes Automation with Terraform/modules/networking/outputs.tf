output "myapp-vpc" {
  value = aws_vpc.myapp-vpc
}

output "igw" {
  value = aws_internet_gateway.igw
}

output "private-subnet-1" {
  value = aws_subnet.private-us-west-1a
}

output "private-subnet-2" {
  value = aws_subnet.private-us-west-1b
}

output "public-subnet-1"{
  value = aws_subnet.public-us-west-1a
}

output "public-subnet-2" {
  value = aws_subnet.public-us-west-1b

}
