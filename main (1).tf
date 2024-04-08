

provider "aws" {
  region = "us-east-1"  
}


resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}


resource "aws_subnet" "public_subnet_zone1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
}


resource "aws_subnet" "private_subnet_zone1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1a"
}


resource "aws_subnet" "public_subnet_zone2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-east-1b"
}


resource "aws_subnet" "private_subnet_zone2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "us-east-1b"
}


resource "aws_instance" "instance_1" {
  ami             = "ami-08d70e59c07c61a3a"
  instance_type   = "t2.micro"
  subnet_id       = aws_subnet.public_subnet_zone1.id
  security_groups = [aws_security_group.sg_web_server.id]
  tags = {
    Name = var.instance1_name
  }
}



resource "aws_instance" "instance_2" {
  ami             = "ami-08d70e59c07c61a3a"
  instance_type   = "t2.micro"
  subnet_id       = aws_subnet.public_subnet_zone2.id
  security_groups = [aws_security_group.sg_web_server.id]
  tags = {
    Name = var.instance2_name
  }
}



resource "aws_security_group" "sg_web_server" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 80
  
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_db_subnet_group" "my_database_subnet" {
  name       = "my_database_subnet"
  subnet_ids = [aws_subnet.private_subnet_zone1.id, aws_subnet.private_subnet_zone2.id]

  tags = {
    Name = "my_database_subnet"
  }
}

resource "aws_security_group" "RDS" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    security_groups = [aws_security_group.sg_web_server.id]
  }
}


resource "aws_db_instance" "my_database" {
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t2.micro"
  name                 = "my_database"
  
  db_subnet_group_name = aws_db_subnet_group.my_database_subnet.name
  vpc_security_group_ids = [aws_security_group.RDS.id]
}
