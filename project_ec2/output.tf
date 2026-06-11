output "eu_north_1_instance" {
  description = "Details of EC2 instance in eu-north-1"
  value = {
    id   = aws_instance.example.id
    type = aws_instance.example.instance_type
  }
}

output "us_east_1_instance" {
  description = "Details of EC2 instance in us-east-1"
  value = {
    id   = aws_instance.example2.id
    type = aws_instance.example2.instance_type
  }
}


