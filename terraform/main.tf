
data "aws_ami" "ubuntu" {

  most_recent = true

  owners = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

}

data "aws_vpc" "default" {
  default = true
}

resource "aws_security_group" "task_sg" {

  name        = "task-tracker-sg"
  description = "Allow API and SSH"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "API access"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH access"
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

  tags = {
    Name      = "task-tracker-sg"
    ManagedBy = "terraform"
  }

}

resource "aws_key_pair" "task_key" {

  key_name   = "task-tracker-key"
  public_key = file("${path.module}/id_ed25519.pub")

}


resource "aws_instance" "task_server" {

  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"

  key_name = aws_key_pair.task_key.key_name

  vpc_security_group_ids = [
    aws_security_group.task_sg.id
  ]

  root_block_device {
    volume_size = 8
    volume_type = "gp3"
  }

  tags = {
    Name        = "task-tracker"
    Environment = "demo"
    ManagedBy   = "terraform"
  }

}