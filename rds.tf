resource "aws_kms_key" "rds_kms_key" {
  description              = "KMS key for RDS encryption"
  deletion_window_in_days  = 7
  enable_key_rotation      = true
  customer_master_key_spec = "SYMMETRIC_DEFAULT"
  multi_region             = true
}

resource "aws_kms_key_policy" "rds_kms_key_policy" {
  key_id = aws_kms_key.rds_kms_key.id

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Id" : "key-for-rds",
    "Statement" : [
      {
        "Sid" : "Enable IAM User Permissions",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "arn:aws:iam::${data.aws_caller_identity.current.id}:root"
        },
        "Action" : "kms:*",
        "Resource" : "*"
      },
      {
        "Sid" : "Allow use of the key",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "arn:aws:iam::${data.aws_caller_identity.current.id}:role/aws-service-role/rds.amazonaws.com/AWSServiceRoleForRDS"
        },
        "Action" : [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ],
        "Resource" : "*"
      },
      {
        "Sid" : "Allow attachment of persistent resources",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "arn:aws:iam::${data.aws_caller_identity.current.id}:role/aws-service-role/rds.amazonaws.com/AWSServiceRoleForRDS"
        },
        "Action" : [
          "kms:CreateGrant",
          "kms:ListGrants",
          "kms:RevokeGrant"
        ],
        "Resource" : "*",
        "Condition" : {
          "Bool" : {
            "kms:GrantIsForAWSResource" : "true"
          }
        }
      },
      {
        "Sid" : "Allow key policy updates",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "arn:aws:iam::${data.aws_caller_identity.current.id}:root"
        },
        "Action" : "kms:PutKeyPolicy",
        "Resource" : "*"
      }
    ]
  })
}

# Fetch the secret version
data "aws_secretsmanager_secret_version" "rds_password_value" {
  secret_id  = aws_secretsmanager_secret.new_rds_password.id # Reference the created secret
  depends_on = [aws_secretsmanager_secret_version.rds_password_value]
}

resource "aws_db_instance" "database" {
  allocated_storage      = 10
  db_name                = "csye6225"
  engine                 = "mysql"
  engine_version         = "5.7"
  instance_class         = "db.t3.micro"
  identifier             = "csye6225"
  username               = "csye6225"
  password               = jsondecode(data.aws_secretsmanager_secret_version.rds_password_value.secret_string)["password"]
  parameter_group_name   = aws_db_parameter_group.mysql57_pg.name
  skip_final_snapshot    = true
  multi_az               = false
  vpc_security_group_ids = [aws_security_group.database_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.database.id
  storage_encrypted      = true
  kms_key_id             = aws_kms_key.rds_kms_key.arn
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