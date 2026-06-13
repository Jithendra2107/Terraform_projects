provider "aws" {
    region = "eu-north-1"
}

resource "aws_key_pair" "my_key" {
    key_name   = "my_key"
    public_key = file("~/.ssh/id_rsa.pub")
}

resource "aws_vpc" "my_vpc" {
    cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "main" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "eu-north-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "Main"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.my_vpc.id
}

resource "aws_route_table" "r" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.main.id
  route_table_id = aws_route_table.r.id
}

resource "aws_security_group" "allow" {
  name        = "allow"
  description = "Allow SSH & HTTP inbound traffic"
  vpc_id      = aws_vpc.my_vpc.id

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

resource "aws_instance" "web" {
  ami           = "ami-05d62b9bc5a6ca605" 
  instance_type = "t3.micro"
  key_name      = aws_key_pair.my_key.key_name
  subnet_id     = aws_subnet.main.id
  vpc_security_group_ids = [aws_security_group.allow.id]

  tags = {
    Name = "WebServer"
  }
  
  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("~/.ssh/id_rsa")
    host        = self.public_ip
  }

  provisioner "file" {
  source      = "app.py"
  destination = "/home/ubuntu/app.py"
  }

  provisioner "remote-exec" {
    inline = [
        "echo 'Hello from the remote instance'",
        "sudo apt update",
        "sudo apt install -y python3-pip python3-venv",
        "cd /home/ubuntu && python3 -m venv venv",
        "cd /home/ubuntu && ./venv/bin/pip install flask",
        "cd /home/ubuntu && nohup ./venv/bin/python app.py > flask.log 2>&1 &"
    ]
  }
}

output "instance_ip" {
  value = aws_instance.web.public_ip
}