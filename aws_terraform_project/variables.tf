variable "vpc_cidr_block" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = "1.0.0.0/16"
}

variable "subnet_cidr_block1" {
  description = "The CIDR block for the subnet"
  type        = string
  default     = "1.0.0.0/24"
}

variable "subnet_cidr_block2" {
  description = "The CIDR block for the second subnet"
  type        = string
  default     = "1.0.1.0/24"
}

variable "instance_type" {
  description = "The type of EC2 instance to create"
  type        = string
  default     = "t3.micro"
}

variable "ami_id" {
  description = "The AMI ID for the EC2 instance"
  type        = string
  default     = "ami-05d62b9bc5a6ca605"
}