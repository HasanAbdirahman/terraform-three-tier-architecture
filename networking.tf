locals {
  public_subnets  = [for subnet in var.subnets_config : subnet if subnet.isPublic]
  private_subnets = [for subnet in var.subnets_config : subnet if !subnet.isPublic]
  Access          = [for subnet in var.subnets_config : subnet.isPublic ? "Public" : "Private"]
}

output "access" {
  value = local.Access
}
output "public_subnets" {
  value = local.public_subnets
}

resource "aws_vpc" "custom_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "Custom VPC"
  }
}

data "aws_availability_zones" "name" {
  state = "available"
}

resource "aws_subnet" "private" {
  count                   = length(local.private_subnets)
  vpc_id                  = aws_vpc.custom_vpc.id
  cidr_block              = local.private_subnets[count.index].cidr_block
  availability_zone       = data.aws_availability_zones.name.names[count.index % length(data.aws_availability_zones.name.names)]
  map_public_ip_on_launch = false
  tags = {
    Name   = "Private Subnet ${count.index + 1}"
    Access = "private"
  }
}

resource "aws_subnet" "public" {
  count                   = length(local.public_subnets)
  vpc_id                  = aws_vpc.custom_vpc.id
  cidr_block              = local.public_subnets[count.index].cidr_block
  availability_zone       = data.aws_availability_zones.name.names[count.index % length(data.aws_availability_zones.name.names)]
  map_public_ip_on_launch = true
  tags = {
    Name   = "Public Subnet ${count.index + 1}"
    Access = "public"
  }
}


resource "aws_internet_gateway" "igw" {
  count  = length(local.public_subnets) > 0 ? 1 : 0
  vpc_id = aws_vpc.custom_vpc.id
  tags = {
    Name = "IGW"
  }
}

resource "aws_route_table" "rtb" {
  count  = length(local.public_subnets) > 0 ? 1 : 0
  vpc_id = aws_vpc.custom_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw[0].id
  }
  tags = {
    Name = "RTB"

  }
}


resource "aws_route_table_association" "this" {
  for_each       = { for idx, subnet in aws_subnet.public : idx => subnet }
  subnet_id      = each.key
  route_table_id = aws_route_table.rtb[0].id
}
