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
