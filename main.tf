terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.28.0"
    }
  }
}

provider "aws" {
  region = "ap-south-1"
}

locals {
  Name = "project-01"
}

resource "aws_vpc" "my-vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "${local.Name}-vpc"
  }
}

resource "aws_subnet" "my-subnet" {
  vpc_id     = aws_vpc.my-vpc.id
  cidr_block = "10.0.${count.index}.0/24"
  count      = 2
  tags = {
    Name = "${local.Name}-subnet-${count.index}"
  }
}

# Creating EC2 instances based on variable configuration
resource "aws_instance" "my_server" {
  for_each = var.ec2_map

  ami = each.value.ami
  instance_type = each.value.instance_type

  subnet_id     = element(aws_subnet.my-subnet.*.id, index(keys(var.ec2_map), each.key) % length(aws_subnet.my-subnet))
  tags = {
    Name = "${local.Name}-instance-${each.key}"
  }
}
# # Creating EC2 instances based on variable configuration
# resource "aws_instance" "my_server" {
#   count = length(var.ec2_config)

#   ami           = var.ec2_config[count.index].ami
#   instance_type = var.ec2_config[count.index].instance_type

#   subnet_id     = element(aws_subnet.my-subnet.*.id, count.index % length(aws_subnet.my-subnet))
#   tags = {
#     Name = "${local.Name}-instance-${count.index}"
#   }
# }
# # Creating 4 EC2 instances
# resource "aws_instance" "my_server" {
#   ami           = "ami-02b8269d5e85954ef"
#   instance_type = "t3.micro"
#   count         = 4
#   subnet_id     = element(aws_subnet.my-subnet.*.id, count.index % length(aws_subnet.my-subnet))
#   tags = {
#     Name = "${local.Name}-instance-${count.index}"
#   }
# }
output "name" {
  value = aws_subnet.my-subnet[0].id
}
