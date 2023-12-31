provider "aws" {
  region = var.region
}

resource "aws_vpc" "some_custom_vpc" {
  cidr_block = var.vpc_cidr_block

  tags = {
    Name = "Some Custom VPC"
  }
}

resource "aws_subnet" "some_public_subnet" {
  vpc_id            = aws_vpc.some_custom_vpc.id
  cidr_block        = var.public_subnet_cidr_block
  availability_zone = "us-east-1a"

  tags = {
    Name = "Some Public Subnet"
  }
}

resource "aws_subnet" "some_private_subnet" {
  vpc_id            = aws_vpc.some_custom_vpc.id
  cidr_block        = var.private_subnet_cidr_block
  availability_zone = "us-east-1a"

  tags = {
    Name = "Some Private Subnet"
  }
}

resource "aws_internet_gateway" "some_ig" {
  vpc_id = aws_vpc.some_custom_vpc.id

  tags = {
    Name = "Some Internet Gateway"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.some_custom_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.some_ig.id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.some_ig.id
  }

  tags = {
    Name = "Public Route Table"
  }
}

resource "aws_route_table_association" "public_1_rt_a" {
  subnet_id      = aws_subnet.some_public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_security_group" "web_sg" {
  name   = "HTTP and SSH"
  vpc_id = aws_vpc.some_custom_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
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

resource "aws_instance" "example" {
  ami           = var.instance_ami
  instance_type = var.instance_type
  key_name      = var.key_name

  tags = {
    Name = "MyEC2Instance"
  }
}

resource "aws_launch_configuration" "example_lc" {
  name          = "example-launch-configuration"
  image_id      = var.instance_ami
  instance_type = var.instance_type
  security_groups = [aws_security_group.web_sg.id]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "example_asg" {
  name                 = "example-autoscaling-group"
  launch_configuration = aws_launch_configuration.example_lc.name
  vpc_zone_identifier  = [aws_subnet.some_public_subnet.id, aws_subnet.some_private_subnet.id]
  min_size             = 1
  max_size             = 3
  desired_capacity     = 2
  target_group_arns    = [aws_lb_target_group.example_tg.arn]

  tag {
    key                 = "Name"
    value               = "example-instance"
    propagate_at_launch = true
  }
}

