provider "aws" {
  region = "eu-north-1"
}

variable "ami" {
    description = "The AMI to use for the instance"
    type        = string
}

variable "instance_type" {
    description = "The type of instance to use"
    type        = string
}

resource "aws_instance" "instance" {
    ami = var.ami
    instance_type = var.instance_type
}