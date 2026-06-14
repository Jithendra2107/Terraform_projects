variable "ami" {
  description = "The AMI ID to use for the EC2 instance"
  type        = string
}

variable "instance_type" {
  description = "The type of EC2 instance to create"
  type = map(string)
  default = {
    "dev" = "t3.micro"
    "staging" = "t3.small"
    "prod" = "c7i-flex.large"
  }
}

module "ec2" {
  source = "./modules/ec2"
  instance_type = lookup(var.instance_type, terraform.workspace, "t3.medium")
  ami = var.ami
}