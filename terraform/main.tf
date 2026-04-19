data "aws_availability_zones" "available" {}

resource "aws_vpc" "certverify" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "certverify-vpc"
  }
}

resource "aws_subnet" "public_1" {
  vpc_id                  = aws_vpc.certverify.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-southeast-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "certverify-public-1"
  }
}

resource "aws_subnet" "public_2" {
  vpc_id                  = aws_vpc.certverify.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "ap-southeast-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "certverify-public-2"
  }
}

resource "aws_internet_gateway" "certverify" {
  vpc_id = aws_vpc.certverify.id

  tags = {
    Name = "certverify-igw"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.certverify.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.certverify.id
  }

  tags = {
    Name = "certverify-public-rt"
  }
}

resource "aws_route_table_association" "public_1" {
  subnet_id      = aws_subnet.public_1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_2" {
  subnet_id      = aws_subnet.public_2.id
  route_table_id = aws_route_table.public.id
}