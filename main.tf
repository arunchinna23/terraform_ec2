provider "aws" {
  region  = "us-east-1"
  access_key = "AKIAVZV6K3H77CF2763W"
  secret_key = "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"
}
resource "aws_vpc" "main" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "myvpc"
  }
}
resource "aws_subnet" "pub" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "mypubsub"
  }
}
resource "aws_subnet" "pvt" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.2.0/24"

  tags = {
    Name = "mypvtsub"
  }
  }
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "mygw"
  }
}
resource "aws_nat_gateway" "natgateway" {
  allocation_id = aws_eip.elasticip.id
  subnet_id = aws_subnet.pub.id
  tags = {
    Name = "mynatgateway"
  }
  depends_on = [aws_internet_gateway.gw]
}
resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  tags = {
    Name = "myrt"
  }
}
resource "aws_security_group" "sg" {
  name        = "sg"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description      = "TLS from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = [aws_vpc.main.cidr_block]
  }
  ingress {
    description      = "TLS from VPC"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = [aws_vpc.main.cidr_block]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "mysg"
  }
}
resource "aws_eip" "elasticip" {
  vpc      = true
}
resource "aws_instance" "ubuntu" {
  ami           = "ami-04505e74c0741db8d"
  instance_type = "t2.micro"
  key_name = "NVirginia"
  subnet_id = aws_subnet.pub.id
  tags = {
    Name = "myubuntu"
  }

}
resource "aws_route_table_association" "ass" {
  subnet_id      = aws_subnet.pub.id
  route_table_id = aws_route_table.rt.id
}
