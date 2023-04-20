#To create a VPC/VNET :
provider "aws" {
    region = "us-east-1"

}

resource "aws_vpc" "my_vpc " {
    cidr_block = "10.0.0.0/16"
    tags = {
        Name = "Terraformvpc"
    }
}



#Create one Private Subnet & Public Subnet:

# Public Subnet configuration
resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.my_vpc.id 
  cidr_block = "10.0.1.0/24"
}

# Private Subnet configuration
resource "aws_subnet" "private" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = "10.0.2.0/24"
}

# Internet Gateway configuration
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.my_vpc.id
}

#Deploy Cloud NAT and enable NATing for Private subnet

# NAT Gateway configuration
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.private.id
}


# Elastic IP address configuration
resource "aws_eip" "nat" {}


# Route table configuration for Public Subnet
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  subnet_association {
    subnet_id = aws_subnet.public.id
  }
}

# Route table configuration for Private Subnet
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  subnet_association {
    subnet_id = aws_subnet.private.id
  }
}

# Virtual Machine configuration
resource "aws_instance" "Ashwin44" {
  ami           = "ami-06e46074ae430fba6"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.private.id
 
  provisioner "remote-exec" {
    inline = [
      "curl ifconfig.co"
    ]
  }
}