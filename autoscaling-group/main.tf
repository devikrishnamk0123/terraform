terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  backend "s3" {
    bucket = "devi-tf-state-file-bucket"
    key = "state-file-tf-task-1"
    region = "us-east-2"
  }
}

provider "aws" {
  region = "us-east-2"
}


locals {
    bucket_names = ["devisbucket1","devisbucket2","devisbucket3"]
}

resource "aws_s3_bucket" "bucket" {
    bucket = var.bucket_name
    
}

resource "aws_s3_bucket" "bucket2" {
    count = 3
  bucket = local.bucket_names[count.index]
}
resource "aws_launch_template" "sample-launch-template" {
    name = var.launch_template_name
    instance_type = var.instance_type
    image_id = var.image_id
    tags = var.tags

}

resource "aws_vpc" "tf-vpc" {
    tags = {
        Name = var.vpc_name
    }
    cidr_block = var.cidr_block_vpc
}

resource "aws_subnet" "sample-subnet" {
    vpc_id = aws_vpc.tf-vpc.id
    tags = {
        Name = var.subnet_name
    }
    cidr_block = var.cidr_block_subnet
    tags_all = var.tags
}

resource "aws_autoscaling_group" "asg" {
  min_size             = 1
  max_size             = 3
  desired_capacity     = 1
  launch_template {
    id = aws_launch_template.sample-launch-template.id
    version = aws_launch_template.sample-launch-template.latest_version
  }
  vpc_zone_identifier = [aws_subnet.sample-subnet.id]
#   tag {
#     key =
#     value = var.tags[0]
#     propagate_at_launch = true
#   }
  
}

output "asg_id" {
    value = aws_autoscaling_group.asg.id
}
# output "instance_ip_addr" {
#   value = aws_instance.public_ip
#   depends_on = [ aws_autoscaling_group.asg ]
# }