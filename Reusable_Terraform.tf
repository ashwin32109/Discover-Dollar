# modules/vpc/script.tf
variable "vpc_cidr_block" {}

resource "aws_vpc" "Ashwin44" {
  cidr_block = var.vpc_cidr_block
}

# modules/subnets/script.tf
variable "vpc_id" {}
variable "public_subnet_cidr" {}
variable "private_subnet_cidr" {}

resource "aws_subnet" "public" {
  vpc_id     = var.vpc_id
  cidr_block = var.public_subnet_cidr
}

resource "aws_subnet" "private" {
  vpc_id     = var.vpc_id
  cidr_block = var.private_subnet_cidr
}

# modules/internet-gateway/script.tf
variable "vpc_id" {}

resource "aws_internet_gateway" "igw" {
  vpc_id = var.vpc_id
}

# modules/nat-gateway/script.tf
variable "private_subnet_id" {}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = var.private_subnet_id
}

resource "aws_eip" "nat" {}

# modules/route-tables/script.tf
variable "vpc_id" {}
variable "public_subnet_id" {}
variable "private_subnet_id" {}

resource "aws_route_table" "public" {
  vpc_id = var.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  subnet_association {
    subnet_id = var.public_subnet_id
  }
}

resource "aws_route_table" "private" {
  vpc_id = var.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  subnet_association {
    subnet_id = var.private_subnet_id
  }
}

# modules/vm/script.tf
variable "private_subnet_id" {}
variable "ami" {}
variable "instance_type" {}

resource "aws_instance" "example" {
  ami           = var.ami
  instance_type = var.instance_type
  subnet_id     = var.private_subnet_id

  provisioner "remote-exec" {
    inline = [
      "curl ifconfig.co"
    ]
  }
}

# script.tf

module "aws_vpc" {
  source = "./modules/aws_vpc"

  vpc_cidr_block = "10.0.0.0/16"
}

module "aws_subnet" {
  source = "./modules/aws_subnet"

  vpc_id              = module.aws_vpc.vpc.id
  public_subnet_cidr  = "10.0.1.0/24"
  private_subnet_cidr = "10.0.2.0/24"
}

module "aws_nat_gateway" {
  source = "./modules/aws_nat_gateway"

  private_subnet_id = module.aws_subnet.private.id
}

module "aws_route_table" {
  source = "./modules/aws_route_table"

  vpc_id            = module.aws_vpc.vpc.id
public_subnet_id = module.aws_subnet.public.id
private_subnet_id = module.aws_subnet.private.id
}

module "aws_vm" {
source = "./modules/aws_vm"

private_subnet_id = module.aws_subnet.private.id
ami = "ami-1234567890abcdef0"
instance_type = "t2.micro"
}
