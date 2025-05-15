data "aws_ami" "os_image" {
  owners = ["099720109477"]
  most_recent = true
  filter {
    name   = "state"
    values = ["available"]
  }
  filter {
    name = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/*24.04-amd64*"]
  }
}

# Key Pair
resource "aws_key_pair" "ec2-key" {
  key_name   = "terra-key-easyshop"
  public_key = file("terra-key-easyshop.pub")
}

#vpc
resource "aws_default_vpc" "default" {

}

# Security Group
resource "aws_security_group" "my_security_group" {
  name        = "easyshop-app-sg"
  description = "This is security group"
  vpc_id      = aws_default_vpc.default.id

  ingress {
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
    protocol    = "tcp"
  }

  ingress {
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
    protocol    = "tcp"
  }

  ingress {
    from_port   = 443
    to_port     = 443
    cidr_blocks = ["0.0.0.0/0"]
    protocol    = "tcp"
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    cidr_blocks = ["0.0.0.0/0"]
    protocol    = "tcp"
  }

  egress {
    from_port   = 0
    to_port     = 0 
    cidr_blocks = ["0.0.0.0/0"]
    protocol    = "-1"
  }

  tags = {
    Name        = "-easyshop-app-sg"
  }
}

#ec2 instance
resource "aws_instance" "my_instance" {
  ami           = data.aws_ami.os_image.id
  instance_type = var.instance_type
  key_name      = aws_key_pair.ec2-key.key_name
  security_groups = [aws_security_group.my_security_group.name]
  user_data = file("${path.module}/installtools.sh")

 
  tags = {
    Name        = "easyshop-app"
  }

  root_block_device {
    volume_size = 30
    volume_type = "gp3"
  } 
}