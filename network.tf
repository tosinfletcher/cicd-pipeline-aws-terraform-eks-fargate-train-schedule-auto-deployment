resource "aws_vpc" "vpc" {
  cidr_block         = var.cidr_block
  instance_tenancy   = "default"
  enable_dns_support = true

  tags = {
    Name = "vpc"
  }
}


resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "igw"
  }
}


resource "aws_default_route_table" "default_rt" {
  default_route_table_id = aws_vpc.vpc.default_route_table_id

  tags = {
    Name = "default_rt"
  }
}


resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public_rt"
  }
}


resource "aws_subnet" "public_1" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.cidr_public_subnet_1
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name                     = "public_1"
    "kubernetes.io/role/elb" = 1
  }

  depends_on = [aws_vpc.vpc, aws_internet_gateway.igw]
}


resource "aws_subnet" "public_2" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.cidr_public_subnet_2
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name                     = "public_2"
    "kubernetes.io/role/elb" = 1
  }

  depends_on = [aws_vpc.vpc, aws_internet_gateway.igw]
}


resource "aws_subnet" "public_3" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.cidr_public_subnet_3
  availability_zone       = "us-east-1c"
  map_public_ip_on_launch = true

  tags = {
    Name                     = "public_3"
    "kubernetes.io/role/elb" = 1
  }

  depends_on = [aws_vpc.vpc, aws_internet_gateway.igw]
}


resource "aws_route_table_association" "public_rt_1" {
  subnet_id      = aws_subnet.public_1.id
  route_table_id = aws_route_table.public_rt.id
}


resource "aws_route_table_association" "public_rt_2" {
  subnet_id      = aws_subnet.public_2.id
  route_table_id = aws_route_table.public_rt.id
}


resource "aws_route_table_association" "public_rt_3" {
  subnet_id      = aws_subnet.public_3.id
  route_table_id = aws_route_table.public_rt.id
}


resource "aws_eip" "eip_1" {
  vpc = true
}


resource "aws_eip" "eip_2" {
  vpc = true
}


resource "aws_eip" "eip_3" {
  vpc = true
}


resource "aws_nat_gateway" "ngw_public_1" {
  allocation_id = aws_eip.eip_1.id
  subnet_id     = aws_subnet.public_1.id
  depends_on    = [aws_internet_gateway.igw]

  tags = {
    Name = "ngw_public_1"
  }
}


resource "aws_nat_gateway" "ngw_public_2" {
  allocation_id = aws_eip.eip_2.id
  subnet_id     = aws_subnet.public_2.id
  depends_on    = [aws_internet_gateway.igw]

  tags = {
    Name = "ngw_public_2"
  }
}


resource "aws_nat_gateway" "ngw_public_3" {
  allocation_id = aws_eip.eip_3.id
  subnet_id     = aws_subnet.public_3.id
  depends_on    = [aws_internet_gateway.igw]

  tags = {
    Name = "ngw_public_3"
  }
}


resource "aws_route_table" "private_rt_1" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.ngw_public_1.id
  }

  tags = {
    Name = "private_rt_1"
  }
}


resource "aws_route_table" "private_rt_2" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.ngw_public_2.id
  }

  tags = {
    Name = "private_rt_2"
  }
}


resource "aws_route_table" "private_rt_3" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.ngw_public_3.id
  }

  tags = {
    Name = "private_rt_3"
  }
}



resource "aws_subnet" "private_1" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.cidr_private_subnet_1
  availability_zone = "us-east-1a"

  tags = {
    Name                              = "private_1"
    "kubernetes.io/role/internal-elb" = 1
  }
}


resource "aws_subnet" "private_2" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.cidr_private_subnet_2
  availability_zone = "us-east-1b"

  tags = {
    Name                              = "private_2"
    "kubernetes.io/role/internal-elb" = 1
  }
}


resource "aws_subnet" "private_3" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.cidr_private_subnet_3
  availability_zone = "us-east-1c"

  tags = {
    Name                              = "private_3"
    "kubernetes.io/role/internal-elb" = 1
  }
}



resource "aws_route_table_association" "private_rt_1" {
  subnet_id      = aws_subnet.private_1.id
  route_table_id = aws_route_table.private_rt_1.id
}


resource "aws_route_table_association" "private_rt_2" {
  subnet_id      = aws_subnet.private_2.id
  route_table_id = aws_route_table.private_rt_2.id
}


resource "aws_route_table_association" "private_rt_3" {
  subnet_id      = aws_subnet.private_3.id
  route_table_id = aws_route_table.private_rt_3.id
}



resource "aws_security_group" "public_sg" {
  name        = "public_sg"
  description = "Allow SSH, HTTP, HTTPs inbound"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "SSH from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "public_sg"
  }

}

