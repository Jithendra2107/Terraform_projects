resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr_block
}

resource "aws_subnet" "subnet1" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.subnet_cidr_block1
  availability_zone       = "eu-north-1a"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "subnet2" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.subnet_cidr_block2
  availability_zone       = "eu-north-1b"
  map_public_ip_on_launch = true
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
}

resource "aws_route_table" "route_table" {
  vpc_id = aws_vpc.vpc.id

  route {
    gateway_id = aws_internet_gateway.igw.id
    cidr_block = "0.0.0.0/0"
  }
}

resource "aws_route_table_association" "subnet1_association" {
  subnet_id      = aws_subnet.subnet1.id
  route_table_id = aws_route_table.route_table.id
}

resource "aws_route_table_association" "subnet2_association" {
  subnet_id      = aws_subnet.subnet2.id
  route_table_id = aws_route_table.route_table.id
}

resource "aws_security_group" "sg" {
  name        = "allow_ssh"
  description = "Allow SSH inbound traffic"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "web_server1" {
  ami             = var.ami_id
  instance_type   = var.instance_type
  subnet_id       = aws_subnet.subnet1.id
  vpc_security_group_ids = [aws_security_group.sg.id]
  user_data       = file("metadata_1.sh")

  tags = {
    Name = "WebServer"
  }
}

resource "aws_instance" "web_server2" {
  ami             = var.ami_id
  instance_type   = var.instance_type
  subnet_id       = aws_subnet.subnet2.id
  vpc_security_group_ids = [aws_security_group.sg.id]
  user_data       = file("metadata_2.sh")

  tags = {
    Name = "WebServer"
  }
}

resource "aws_lb" "alb" {
  name               = "my-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.sg.id]
  subnets            = [aws_subnet.subnet1.id, aws_subnet.subnet2.id]

  tags = {
    Name = "my-alb"
  }
}

resource "aws_lb_target_group" "target_group" {
  name     = "my-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc.id

  health_check {
    path     = "/"
    protocol = "HTTP"
  }

  tags = {
    Name = "my-target-group"
  }
}

resource "aws_lb_target_group_attachment" "web_server1_attachment" {
  target_group_arn = aws_lb_target_group.target_group.arn
  target_id        = aws_instance.web_server1.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "web_server2_attachment" {
  target_group_arn = aws_lb_target_group.target_group.arn
  target_id        = aws_instance.web_server2.id
  port             = 80
}

resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group.arn
  }
}

output "alb_dns_name" {
  value = aws_lb.alb.dns_name
}