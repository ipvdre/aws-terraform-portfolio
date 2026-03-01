resource "aws_vpc" "main" {
    cidr_block = var.vpc_cidr_block
    enable_dns_support = true
    enable_dns_hostnames = true

    tags = {
        Name = "main-vpc"
    }

    lifecycle {
        prevent_destroy = true
    }
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
    vpc_id = aws_vpc.main.id

    tags = {
        Name = "main-igw"
    }
}

# Elastic IP for NAT Gateway
resource "aws_eip" "nat" {
    domain = "vpc"

    tags = {
        Name = "nat-eip"
    }

    depends_on = [aws_internet_gateway.main]
}

# NAT Gateway (lives in the public subnet)
resource "aws_nat_gateway" "main" {
    allocation_id = aws_eip.nat.id
    subnet_id     = aws_subnet.public.id

    tags = {
        Name = "main-nat-gateway"
    }

    depends_on = [aws_internet_gateway.main]
}

# Public Subnet (subnet-a)
resource "aws_subnet" "public" {
    cidr_block = var.subnet_cidr_a
    vpc_id = aws_vpc.main.id
    availability_zone = var.availability_zone_a

    tags = {
        Name = "public-subnet-a"
    }
}

# Private Subnet (subnet-b)
resource "aws_subnet" "private" {
    cidr_block = var.subnet_cidr_b
    vpc_id = aws_vpc.main.id
    availability_zone = var.availability_zone_b

    tags = {
        Name = "private-subnet-b"
    }
}

# Public Route Table
resource "aws_route_table" "public" {
    vpc_id = aws_vpc.main.id

    tags = {
        Name = "public-route-table"
    }
}

resource "aws_route" "public-internet" {
    route_table_id         = aws_route_table.public.id
    destination_cidr_block = "0.0.0.0/0"
    gateway_id             = aws_internet_gateway.main.id
}

resource "aws_route_table_association" "public" {
    subnet_id      = aws_subnet.public.id
    route_table_id = aws_route_table.public.id
}

# Private Route Table
resource "aws_route_table" "private" {
    vpc_id = aws_vpc.main.id

    tags = {
        Name = "private-route-table"
    }
}

resource "aws_route" "private-nat" {
    route_table_id         = aws_route_table.private.id
    destination_cidr_block = "0.0.0.0/0"
    nat_gateway_id         = aws_nat_gateway.main.id
}

resource "aws_route_table_association" "private" {
    subnet_id      = aws_subnet.private.id
    route_table_id = aws_route_table.private.id
}
