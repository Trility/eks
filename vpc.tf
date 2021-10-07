resource "aws_vpc" "vpc" {
  cidr_block = var.cidr_block_vpc
  enable_dns_hostnames = true
  tags = {
    Name = "eks-${var.cluster_name}"
  }
}

output "vpc_id" {
  value = aws_vpc.vpc.id
}

resource "aws_subnet" "private_az1" {
  vpc_id = aws_vpc.vpc.id
  availability_zone_id = "usw2-az1"
  cidr_block = var.cidr_block_subnet_private_az1
  tags = {
    Name = "eks-${var.cluster_name}-private-az1"
    #    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb" = "1"
  }
}

resource "aws_subnet" "private_az2" {
  vpc_id = aws_vpc.vpc.id
  availability_zone_id = "usw2-az2"
  cidr_block = var.cidr_block_subnet_private_az2
  tags = {
    Name = "eks-${var.cluster_name}-private-az2"
    #"kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb" = "1"
  }
}

resource "aws_subnet" "private_az3" {
  vpc_id = aws_vpc.vpc.id
  availability_zone_id = "usw2-az3"
  cidr_block = var.cidr_block_subnet_private_az3
  tags = {
    Name = "eks-${var.cluster_name}-private-az3"
    #"kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb" = "1"
  }
}

resource "aws_subnet" "private_az4" {
  vpc_id = aws_vpc.vpc.id
  availability_zone_id = "usw2-az4"
  cidr_block = var.cidr_block_subnet_private_az4
  tags = {
    Name = "eks-${var.cluster_name}-private-az4"
    #"kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb" = "1"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "eks-${var.cluster_name}-private"
  }
}

resource "aws_route_table_association" "private_az1" {
  route_table_id = aws_route_table.private.id
  subnet_id = aws_subnet.private_az1.id
}

resource "aws_route_table_association" "private_az2" {
  route_table_id = aws_route_table.private.id
  subnet_id = aws_subnet.private_az2.id
}

resource "aws_route_table_association" "private_az3" {
  route_table_id = aws_route_table.private.id
  subnet_id = aws_subnet.private_az3.id
}

resource "aws_route_table_association" "private_az4" {
  route_table_id = aws_route_table.private.id
  subnet_id = aws_subnet.private_az4.id
}

resource "aws_subnet" "public_az1" {
  vpc_id = aws_vpc.vpc.id
  availability_zone_id = "usw2-az1"
  cidr_block = var.cidr_block_subnet_public_az1
  tags = {
    Name = "eks-${var.cluster_name}-public_az1"
    #"kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }
}

resource "aws_subnet" "public_az2" {
  vpc_id = aws_vpc.vpc.id
  availability_zone_id = "usw2-az2"
  cidr_block = var.cidr_block_subnet_public_az2
  tags = {
    Name = "eks-${var.cluster_name}-public_az2"
    #"kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "eks-${var.cluster_name}-public"
  }
}

resource "aws_route_table_association" "public_az1" {
  route_table_id = aws_route_table.public.id
  subnet_id = aws_subnet.public_az1.id
}

resource "aws_route_table_association" "public_az2" {
  route_table_id = aws_route_table.public.id
  subnet_id = aws_subnet.public_az2.id
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "eks-${var.cluster_name}"
  }
}

resource "aws_route" "igw" {
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.igw.id
  route_table_id = aws_route_table.public.id
}

resource "aws_eip" "ngw" {
  vpc = true
  tags = {
    Name = "eks-${var.cluster_name}-nat-gateway"
  }
}

resource "aws_nat_gateway" "ngw" {
  allocation_id = aws_eip.ngw.id
  subnet_id = aws_subnet.public_az1.id
  tags = {
    Name = "eks-${var.cluster_name}"
  }
}

output "vpn_attach_subnet" {
  value = aws_subnet.public_az1.id
}

resource "aws_route" "ngw" {
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.ngw.id
  route_table_id = aws_route_table.private.id
}
