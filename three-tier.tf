provider "aws" {
  region = "ap-south-1"
}

# ---------------- VPC ----------------
resource "aws_vpc" "three_tier_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  tags = { Name = "three-tier-vpc" }
}

# ---------------- Subnets ----------------
# Public subnets for Web Tier
resource "aws_subnet" "public_subnet" {
  count                   = 2
  vpc_id                  = aws_vpc.three_tier_vpc.id
  cidr_block              = cidrsubnet(aws_vpc.three_tier_vpc.cidr_block, 4, count.index)
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  tags = { Name = "public-subnet-${count.index+1}" }
}

# Private subnets for App & DB Tiers
resource "aws_subnet" "private_app_subnet" {
  count             = 2
  vpc_id            = aws_vpc.three_tier_vpc.id
  cidr_block        = cidrsubnet(aws_vpc.three_tier_vpc.cidr_block, 4, count.index + 2)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = { Name = "private-app-subnet-${count.index+1}" }
}

resource "aws_subnet" "private_db_subnet" {
  count             = 2
  vpc_id            = aws_vpc.three_tier_vpc.id
  cidr_block        = cidrsubnet(aws_vpc.three_tier_vpc.cidr_block, 4, count.index + 4)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = { Name = "private-db-subnet-${count.index+1}" }
}

# ---------------- Internet Gateway & NAT ----------------
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.three_tier_vpc.id
  tags   = { Name = "three-tier-igw" }
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_subnet[0].id
  tags          = { Name = "nat-gateway" }
}

resource "aws_eip" "nat" {
  vpc = true
}

# ---------------- Security Groups ----------------
# Web SG
resource "aws_security_group" "web_sg" {
  name        = "web-sg"
  vpc_id      = aws_vpc.three_tier_vpc.id
  description = "Allow HTTP/HTTPS"
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
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

# App SG
resource "aws_security_group" "app_sg" {
  name        = "app-sg"
  vpc_id      = aws_vpc.three_tier_vpc.id
  description = "Allow traffic from web tier"
  ingress {
    from_port       = 4000
    to_port         = 4000
    protocol        = "tcp"
    security_groups = [aws_security_group.web_sg.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# DB SG
resource "aws_security_group" "db_sg" {
  name        = "db-sg"
  vpc_id      = aws_vpc.three_tier_vpc.id
  description = "Allow traffic from app tier only"
  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.app_sg.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ---------------- RDS MySQL ----------------
resource "aws_db_subnet_group" "rds_subnet" {
  name       = "rds-subnet-group"
  subnet_ids = aws_subnet.private_db_subnet[*].id
}

resource "aws_db_instance" "three_tier_db" {
  allocated_storage    = 20
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t4g.micro"
  name                 = "three-tier-db"
  username             = "dbadmin"
  password             = "dbuser1234"
  db_subnet_group_name = aws_db_subnet_group.rds_subnet.name
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  skip_final_snapshot  = true
  publicly_accessible  = false
}