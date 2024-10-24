resource "random_password" "password" {
  length  = 16
  special = false
}

resource "aws_db_instance" "database" {
  allocated_storage      = 10
  db_name                = "csye6225"
  engine                 = "mysql"
  engine_version         = "5.7"
  instance_class         = "db.t3.micro"
  identifier             = "csye6225"
  username               = "csye6225"
  password               = random_password.password.result
  parameter_group_name   = aws_db_parameter_group.mysql57_pg.name
  skip_final_snapshot    = true
  multi_az               = false
  vpc_security_group_ids = [aws_security_group.database_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.database.id
}

resource "aws_security_group" "database_sg" {
  name        = "database"
  description = "Allow inbound traffic to 3306 from VPC"
  vpc_id      = aws_vpc.main_vpc.id

  ingress {
    description     = "open port 3306 to vpc"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.app_sg.id]
  }

  # egress {
  #   from_port   = 0
  #   to_port     = 0
  #   protocol    = -1
  #   cidr_blocks = ["0.0.0.0/0"]
  # }

  tags = {
    Name = "database"
  }
}

resource "aws_db_subnet_group" "database" {
  name       = "database"
  subnet_ids = [aws_subnet.private_subnet[0].id, aws_subnet.private_subnet[1].id]

  tags = {
    Name = "database subnet group"
  }
}

resource "aws_db_parameter_group" "mysql57_pg" {
  name   = "webapp-database-pg"
  family = "mysql5.7"
}