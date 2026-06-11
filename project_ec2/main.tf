resource "aws_instance" "example" {
  provider = aws.eu-north-1
  ami           = var.eu_north_1_ami_id
  instance_type = var.instance_type1
}

resource "aws_instance" "example2" {
  provider = aws.us-east-1
  ami           = var.us_east_1_ami_id
  instance_type = var.instance_type2
}