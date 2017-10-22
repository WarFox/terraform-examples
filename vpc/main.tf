provider "aws" {
  region = "eu-west-1"
}

# Create a VPC
resource "aws_vpc" "company_vpc" {
  cidr_block                       = "10.0.0.0/16"
  enable_dns_support               = true
  enable_dns_hostnames             = true
  assign_generated_ipv6_cidr_block = false

  tags {
    Name        = "company_vpc"
    Environment = "${var.environment}"
  }
}

# Create a public subnet in the VPC that we created above
resource "aws_subnet" "public_subnet" {
  availability_zone       = "eu-west-1a"
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = "true"
  vpc_id                  = "${aws_vpc.company_vpc.id}"

  tags {
    Name        = "10.0.1.0-eu-west-1a-public"
    Environment = "${var.environment}"
  }
}

# Data provider for our public subnet
data "aws_subnet" "public_subnet" {
  id = "${aws_subnet.public_subnet.id}"
}

# Create a private subnet in the VPC that we created above
resource "aws_subnet" "private_subnet" {
  availability_zone = "eu-west-1b"
  cidr_block        = "10.0.2.0/24"
  vpc_id            = "${aws_vpc.company_vpc.id}"

  tags {
    Name        = "10.0.2.0-eu-west-1b-private"
    Environment = "${var.environment}"
  }
}

# Internet gateway for getting access to internet
resource "aws_internet_gateway" "company_igw" {
  vpc_id = "${aws_vpc.company_vpc.id}"

  tags {
    Name        = "company_igw"
    Environment = "${var.environment}"
  }
}

# Create a route table for associating public routes
resource "aws_route_table" "public_route_table" {
  vpc_id = "${aws_vpc.company_vpc.id}"

  tags {
    Name        = "public_route"
    Environment = "${var.environment}"
  }
}

# Route to internet, using internet gateway
resource "aws_route" "internet_access" {
  route_table_id         = "${aws_route_table.public_route_table.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.company_igw.id}"
}

# Associate internet access route table to our public subnet
resource "aws_route_table_association" "public_subnet_association" {
  route_table_id = "${aws_route_table.public_route_table.id}"
  subnet_id      = "${aws_subnet.public_subnet.id}"
}

# Create an elastic ip
resource "aws_eip" "nat_eip" {
  vpc        = "true"
  depends_on = ["aws_internet_gateway.company_igw"]
}

# Create a NAT gateway in public subnet.
resource "aws_nat_gateway" "company_nat" {
  allocation_id = "${aws_eip.nat_eip.id}"
  subnet_id     = "${aws_subnet.public_subnet.id}"
  depends_on    = ["aws_internet_gateway.company_igw"]
}

# Create a route table for our private route table
resource "aws_route_table" "private_route_table" {
  vpc_id = "${aws_vpc.company_vpc.id}"

  tags {
    Name = "private_route"
    Environment = "${var.environment}"
  }
}

# Route to internet, using NAT gateway
resource "aws_route" "private_route" {
  route_table_id  = "${aws_route_table.private_route_table.id}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = "${aws_nat_gateway.company_nat.id}"
}

# Associate private route table to, private subnet
resource "aws_route_table_association" "private_subnet_association" {
  subnet_id = "${aws_subnet.private_subnet.id}"
  route_table_id = "${aws_route_table.private_route_table.id}"
}
