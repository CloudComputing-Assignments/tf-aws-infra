resource "random_uuid" "uuid" {
}

# Define the KMS Key for S3
resource "aws_kms_key" "s3" {
  description              = "KMS key for S3 bucket encryption"
  customer_master_key_spec = "SYMMETRIC_DEFAULT"
  enable_key_rotation      = true

  policy = jsonencode({
    "Version": "2012-10-17",
    "Id": "key-for-s3",
    "Statement": [
      {
        "Sid": "Enable IAM User Permissions",
        "Effect": "Allow",
        "Principal": {
          "AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        },
        "Action": "kms:*",
        "Resource": "*"
      },
      {
        "Sid": "Allow S3 use of the key",
        "Effect": "Allow",
        "Principal": {
          "Service": "s3.amazonaws.com"
        },
        "Action": [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ],
        "Resource": "*",
        "Condition": {
          "StringEquals": {
            "kms:ViaService": "s3.${var.aws_region}.amazonaws.com",
            "aws:SourceAccount": "${data.aws_caller_identity.current.account_id}"
          }
        }
      },
      {
        "Sid": "Allow attachment of persistent resources",
        "Effect": "Allow",
        "Principal": {
          "Service": "s3.amazonaws.com"
        },
        "Action": [
          "kms:CreateGrant",
          "kms:ListGrants",
          "kms:RevokeGrant"
        ],
        "Resource": "*",
        "Condition": {
          "Bool": {
            "kms:GrantIsForAWSResource": "true"
          },
          "StringEquals": {
            "kms:ViaService": "s3.${var.aws_region}.amazonaws.com"
          }
        }
      }
    ]
  })
}

# Define the S3 Bucket
resource "aws_s3_bucket" "bucket" {
  bucket        = random_uuid.uuid.result
  force_destroy = true

  tags = {
    Name        = "CSYE 6225 webapp"
    Environment = var.aws_profile
  }
}

# Add S3 Bucket Encryption Configuration with the KMS Key
resource "aws_s3_bucket_server_side_encryption_configuration" "s3_encryption" {
  bucket = aws_s3_bucket.bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.s3.arn
    }
  }
}

# Add Lifecycle Configuration to the S3 Bucket
resource "aws_s3_bucket_lifecycle_configuration" "bucket_lifecycle_config" {
  bucket = aws_s3_bucket.bucket.id

  rule {
    id     = "move_to_IA"
    status = "Enabled"

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }
  }
}
