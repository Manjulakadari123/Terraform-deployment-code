provider "aws" {
  region = "us-east-1"
}


#vpc

resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
}


#Internet gateway

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
}


#Public Subnet 

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet
  map_public_ip_on_launch = true
}


#private Subnet

resource "aws_subnet" "private" {
  vpc_id     = aws_vpc.main.id
  cidr_block = var.private_subnet
}


#Route Table

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public_rt.id
}


#Security Group API

resource "aws_security_group" "api_sg" {
  name        = "api-security-group"
  description = "Allow SSH, HTTP, HTTPS for API server"
  vpc_id      = aws_vpc.main.id

  # SSH access (IMPORTANT: restrict to your IP only)
  ingress {
    description = "SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["106.192.4.174/32"]
  }

  # HTTP access
  ingress {
    description = "HTTP access"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTPS access
  ingress {
    description = "HTTPS access"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound traffic (allow all)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "api-sg"
  }
}


# Security Group Worker (RPC)

resource "aws_security_group" "worker_sg" {
  name        = "worker-security-group"
  description = "Allow SSH and API-to-worker communication"
  vpc_id      = aws_vpc.main.id

  # SSH access (ONLY your IP)
  ingress {
    description = "SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
     security_groups = [aws_security_group.api_sg.id]
  }

  # Allow API SG to call worker on port 5000
  ingress {
    description     = "API to Worker communication"
    from_port       = 5000
    to_port         = 5000
    protocol        = "tcp"
    security_groups = [aws_security_group.api_sg.id]
  }

  # Outbound traffic (allow all)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "worker-sg"
  }
}

# AMI
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

#Ec2 for API

resource "aws_instance" "api_vm" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  subnet_id                  = aws_subnet.public.id
  vpc_security_group_ids     = [aws_security_group.api_sg.id]
  associate_public_ip_address = true
   key_name = "test"
}


#Worker 1

resource "aws_instance" "worker1" {
  ami                     = data.aws_ami.ubuntu.id
  instance_type           = var.instance_type
  subnet_id              = aws_subnet.private.id
  vpc_security_group_ids = [aws_security_group.worker_sg.id]
   key_name = "test"
}


#Worker 2

resource "aws_instance" "worker2" {
  ami                     = data.aws_ami.ubuntu.id
  instance_type           = var.instance_type
  subnet_id              = aws_subnet.private.id
  vpc_security_group_ids = [aws_security_group.worker_sg.id]
   key_name = "test"
}




