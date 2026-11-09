terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

locals {
  az_count = length(var.azs)
}

resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.name_prefix}-vpc"
  }
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.name_prefix}-igw"
  }
}

resource "aws_subnet" "public" {
  count = local.az_count

  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = var.azs[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.name_prefix}-public-${var.azs[count.index]}"
    Tier = "public"
  }
}

resource "aws_subnet" "frontend" {
  count = local.az_count

  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.frontend_subnet_cidrs[count.index]
  availability_zone       = var.azs[count.index]
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.name_prefix}-frontend-${var.azs[count.index]}"
    Tier = "frontend"
  }
}

resource "aws_subnet" "backend" {
  count = local.az_count

  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.backend_subnet_cidrs[count.index]
  availability_zone       = var.azs[count.index]
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.name_prefix}-backend-${var.azs[count.index]}"
    Tier = "backend"
  }
}

resource "aws_subnet" "db" {
  count = local.az_count

  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.db_subnet_cidrs[count.index]
  availability_zone       = var.azs[count.index]
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.name_prefix}-db-${var.azs[count.index]}"
    Tier = "database"
  }
}

############################
# NAT Gateway classique — 1 EIP + 1 GW dans le subnet public d'AZ-a
# Partagée par les instances backend (subnets privés).
############################

resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name = "${var.name_prefix}-nat-eip"
  }

  depends_on = [aws_internet_gateway.this]
}

resource "aws_nat_gateway" "this" {
  allocation_id     = aws_eip.nat.id
  subnet_id         = aws_subnet.public[0].id
  connectivity_type = "public"

  tags = {
    Name = "${var.name_prefix}-nat"
  }

  depends_on = [aws_internet_gateway.this]
}

############################
# Tables de routage
############################

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = {
    Name = "${var.name_prefix}-rt-public"
  }
}

resource "aws_route_table_association" "public" {
  count = local.az_count

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Backend : sortie Internet via la NAT Gateway classique (AZ-a). Une seule RT partagée.
resource "aws_route_table" "private_nat" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.this.id
  }

  tags = {
    Name = "${var.name_prefix}-rt-private-nat"
  }
}

resource "aws_route_table_association" "frontend" {
  count = local.az_count

  subnet_id      = aws_subnet.frontend[count.index].id
  route_table_id = aws_route_table.private_nat.id
}

resource "aws_route_table_association" "backend" {
  count = local.az_count

  subnet_id      = aws_subnet.backend[count.index].id
  route_table_id = aws_route_table.private_nat.id
}

# DB : pas de route 0.0.0.0/0 (pas d'accès Internet, y compris via NAT).
resource "aws_route_table" "db" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.name_prefix}-rt-db"
  }
}

resource "aws_route_table_association" "db" {
  count = local.az_count

  subnet_id      = aws_subnet.db[count.index].id
  route_table_id = aws_route_table.db.id
}
