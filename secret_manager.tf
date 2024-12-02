# KMS Key for Secret Manager
resource "aws_kms_key" "secret_manager_key" {
  description             = "KMS key for Secret Manager"
  deletion_window_in_days = 7
  enable_key_rotation     = true
  multi_region            = true
}


resource "aws_kms_key_policy" "secret_manager_key_policy" {
  key_id = aws_kms_key.secret_manager_key.id
  policy = jsonencode({
    "Id" : "key-for-secrets-manager",
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "Enable IAM User Permissions",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        },
        "Action" : "kms:*",
        "Resource" : "*"
      },
      {
        "Sid" : "Allow access for Key Administrators",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling"
        },
        "Action" : [
          "kms:Create*",
          "kms:Describe*",
          "kms:Enable*",
          "kms:List*",
          "kms:Put*",
          "kms:Update*",
          "kms:Revoke*",
          "kms:Disable*",
          "kms:Get*",
          "kms:Delete*",
          "kms:TagResource",
          "kms:UntagResource",
          "kms:ScheduleKeyDeletion",
          "kms:CancelKeyDeletion",
          "kms:CreateGrant"
        ],
        "Resource" : "*"
      },
      {
        "Sid" : "Allow use of the key for Secrets Manager",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "secretsmanager.amazonaws.com"
        },
        "Action" : [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey",
          "kms:CreateGrant"
        ],
        "Resource" : "*"
      },
      {
        "Sid" : "Allow access to the key for RDS",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "rds.amazonaws.com"
        },
        "Action" : [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey",
          "kms:CreateGrant"
        ],
        "Resource" : "*"
      }
    ]
  })
}



resource "aws_secretsmanager_secret" "new_rds_password" {
  name                    = "rds-db-password-v2"
  description             = "Password for RDS database"
  kms_key_id              = aws_kms_key.secret_manager_key.arn
  recovery_window_in_days = 0
  # lifecycle {
  #   prevent_destroy = true
  # }
}

resource "random_password" "password" {
  length  = var.random_password_length
  special = false
}


# Store the generated password as a secret in Secrets Manager
resource "aws_secretsmanager_secret_version" "rds_password_value" {
  secret_id = aws_secretsmanager_secret.new_rds_password.id
  secret_string = jsonencode({
    username = "csye6225"
    password = random_password.password.result # Use the random password here
  })
}

resource "aws_kms_key" "sendgrid_key" {
  description             = "KMS key for SendGrid API secret"
  enable_key_rotation     = true
  deletion_window_in_days = 7
}


resource "aws_secretsmanager_secret" "sendgrid_api_secret" {
  name                    = "sendgrid-api-key-v1"
  description             = "SendGrid API Key"
  recovery_window_in_days = 0
  kms_key_id              = aws_kms_key.sendgrid_key.arn
}

resource "aws_secretsmanager_secret_version" "sendgrid_api_key_value" {
  secret_id = aws_secretsmanager_secret.sendgrid_api_secret.id
  secret_string = jsonencode({
    SENDGRID_API_KEY = var.sendgrid_api
  })
}


