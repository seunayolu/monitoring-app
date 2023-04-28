provider "aws" {
  region = "us-west-2"
}

resource "aws_vpc" "eks-vpc" {
  cidr_block = var.vpc_cidr_block
  enable_dns_hostnames = true
  enable_dns_support = true 
  tags = {
    "Name" = "${var.env_prefix}-VPC"
  }
}

resource "aws_subnet" "eks-public-subnet-01" {
  availability_zone = var.avail_zone[0]
  vpc_id = aws_vpc.eks-vpc.id
  cidr_block = var.subnet_cidr_blocks[0]
  map_public_ip_on_launch = true
  tags = {
    "Name" = "${var.env_prefix}-PUBLIC-SUBNET-AZ-1"
  }
}

resource "aws_subnet" "eks-public-subnet-02" {
  availability_zone = var.avail_zone[1]
  vpc_id = aws_vpc.eks-vpc.id
  cidr_block = var.subnet_cidr_blocks[1]
  map_public_ip_on_launch = true
  tags = {
    "Name" = "${var.env_prefix}-PUBLIC-SUBNET-AZ-2"
  }
}

resource "aws_subnet" "eks-private-subnet-01" {
  availability_zone = var.avail_zone[0]
  vpc_id = aws_vpc.eks-vpc.id
  cidr_block = var.subnet_cidr_blocks[2]
  map_public_ip_on_launch = false
  tags = {
    "Name" = "${var.env_prefix}-PRIVATE-SUBNET-AZ-1"
  }
}

resource "aws_subnet" "eks-private-subnet-02" {
  availability_zone = var.avail_zone[1]
  vpc_id = aws_vpc.eks-vpc.id
  cidr_block = var.subnet_cidr_blocks[3]
  map_public_ip_on_launch = false
  tags = {
    "Name" = "${var.env_prefix}-PRIVATE-SUBNET-AZ-2"
  }
}

resource "aws_internet_gateway" "eks-igw" {
  vpc_id = aws_vpc.eks-vpc.id
  tags = {
    "Name" = "${var.env_prefix}-IGW"
  }
}

resource "aws_eip" "eks-nat-eip-az1" {
  vpc = true
  depends_on = [ aws_internet_gateway.eks-igw ]  
  tags = {
    "Name" = "${var.env_prefix}-NAT-EIP-AZ1"
  }
}

resource "aws_nat_gateway" "eks-nat-az1" {
  allocation_id = aws_eip.eks-nat-eip-az1.id
  subnet_id = aws_subnet.eks-public-subnet-01.id
  tags = {
    "Name" = "${var.env_prefix}-NATG-AZ1"
  }
  
}

resource "aws_eip" "eks-nat-eip-az2" {
  vpc = true
  depends_on = [ aws_internet_gateway.eks-igw ]  
  tags = {
    "Name" = "${var.env_prefix}-NAT-EIP-AZ2"
  }
}

resource "aws_nat_gateway" "eks-nat-az2" {
  allocation_id = aws_eip.eks-nat-eip-az2.id
  subnet_id = aws_subnet.eks-public-subnet-02.id
  tags = {
    "Name" = "${var.env_prefix}-NATG-AZ2"
  }
  
}

resource "aws_route_table" "eks-public-route-table" {
  vpc_id = aws_vpc.eks-vpc.id
  tags = {
    "Name" = "${var.env_prefix}-PUBLIC-RT"
  }
}

resource "aws_route_table" "eks-private-route-table-az1" {
  vpc_id = aws_vpc.eks-vpc.id
  tags = {
    "Name" = "${var.env_prefix}-PRIVATE-RT-AZ1"
  }
}

resource "aws_route_table" "eks-private-route-table-az2" {
  vpc_id = aws_vpc.eks-vpc.id
  tags = {
    "Name" = "${var.env_prefix}-PRIVATE-RT-AZ2"
  }
}

resource "aws_route_table_association" "eks-pub-subnet-01" {
  subnet_id = aws_subnet.eks-public-subnet-01.id
  route_table_id = aws_route_table.eks-public-route-table.id
}

resource "aws_route_table_association" "eks-pub-subnet-02" {
  subnet_id = aws_subnet.eks-public-subnet-02.id
  route_table_id = aws_route_table.eks-public-route-table.id
}

resource "aws_route_table_association" "eks-pub-subnet-03" {
  subnet_id = aws_subnet.eks-private-subnet-01.id
  route_table_id = aws_route_table.eks-private-route-table-az1.id
}

resource "aws_route_table_association" "eks-pub-subnet-04" {
  subnet_id = aws_subnet.eks-private-subnet-02.id
  route_table_id = aws_route_table.eks-private-route-table-az2.id
}

resource "aws_route" "eks-pub-sub-route" {
  destination_cidr_block = var.my_ip
  gateway_id = aws_internet_gateway.eks-igw.id
  route_table_id = aws_route_table.eks-public-route-table.id
}

resource "aws_route" "eks-private-sub-route-az1" {
  destination_cidr_block = var.my_ip
  gateway_id = aws_nat_gateway.eks-nat-az1.id
  route_table_id = aws_route_table.eks-private-route-table-az1.id
}

resource "aws_route" "eks-private-sub-route-az2" {
  destination_cidr_block = var.my_ip
  gateway_id = aws_nat_gateway.eks-nat-az2.id
  route_table_id = aws_route_table.eks-private-route-table-az2.id
}





