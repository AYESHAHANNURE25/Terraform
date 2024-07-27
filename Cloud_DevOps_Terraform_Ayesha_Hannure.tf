provider "aws" {
    region="us-east-1"
    #access_key = "AKIAYR35QEYZYUCBANGW"
    #secret_key = "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"
    alias = "useast1"
}

provider "aws" {
  region = "us-east-2"
  alias  = "useast2"
  access_key = "AKIAYR35QEYZYUCBANGW"
  secret_key = "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"
}


resource "aws_vpc" "useast1" {
  provider   = aws.useast1
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "useast1-vpc"
  }
}

resource "aws_vpc" "useast2" {
  provider   = aws.useast2
  cidr_block = "10.1.0.0/16"
  tags = {
    Name = "useast2-vpc"
  }
}

resource "aws_subnet" "useast1" {
  provider                = aws.useast1
  vpc_id                  = aws_vpc.useast1.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "useast1-subnet"
  }
}

resource "aws_subnet" "useast2" {
  provider                = aws.useast2
  vpc_id                  = aws_vpc.useast2.id
  cidr_block              = "10.1.1.0/24"
  availability_zone       = "us-east-2a"
  map_public_ip_on_launch = true
  tags = {
    Name = "useast2-subnet"
  }
}

resource "aws_internet_gateway" "useast1" {
  provider = aws.useast1
  vpc_id   = aws_vpc.useast1.id
  tags = {
    Name = "useast1-igw"
  }
}

resource "aws_internet_gateway" "useast2" {
  provider = aws.useast2
  vpc_id   = aws_vpc.useast2.id
  tags = {
    Name = "useast2-igw"
  }
}

resource "aws_route_table" "useast1" {
  provider = aws.useast1
  vpc_id   = aws_vpc.useast1.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.useast1.id
  }
  tags = {
    Name = "useast1-route-table"
  }
}

resource "aws_route_table" "useast2" {
  provider = aws.useast2
  vpc_id   = aws_vpc.useast2.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.useast2.id
  }
  tags = {
    Name = "useast2-route-table"
  }
}

resource "aws_route_table_association" "useast1" {
  provider        = aws.useast1
  subnet_id       = aws_subnet.useast1.id
  route_table_id  = aws_route_table.useast1.id
}

resource "aws_route_table_association" "useast2" {
  provider        = aws.useast2
  subnet_id       = aws_subnet.useast2.id
  route_table_id  = aws_route_table.useast2.id
}

resource "aws_security_group" "useast1" {
  provider = aws.useast1
  vpc_id   = aws_vpc.useast1.id
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
  tags = {
    Name = "useast1-sg"
  }
}

resource "aws_security_group" "useast2" {
  provider = aws.useast2
  vpc_id   = aws_vpc.useast2.id
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
  tags = {
    Name = "useast2-sg"
  }
}

resource "aws_instance" "Ins1" {
  ami              = "ami-00beae93a2d981137" # Replace with a valid AMI for your region
  instance_type    = "t2.micro"
  subnet_id        = aws_subnet.useast1.id
  security_groups  = [aws_security_group.useast1.id]

  tags = {
    Name = "useast1-instance"
  }
}

resource "aws_instance" "Inst2" {
  provider         = aws.useast2
  ami              = "ami-0ca2e925753ca2fb4" # Replace with a valid AMI for your region
  instance_type    = "t2.micro"
  subnet_id        = aws_subnet.useast2.id
  security_groups  = [aws_security_group.useast2.id]

  tags = {
    Name = "useast2-instance"
  }
}

/*output "ec2_instance_public_ips" {
  description = "Public IPs of the EC2 instances"
  value = [
    aws_instance.useast1.public_ip,
    aws_instance.useast2.public_ip,
  ]
}*/
