resource "random_uuid" "uuid" {
}
resource "aws_s3_bucket" "bucket" {
  bucket = random_uuid.uuid.result
  force_destroy = true

  tags = {
    Name        = "CSYE 6225 webapp"
    Environment = var.aws_profile
  }
}


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

resource "aws_kms_key" "bucket_key" {
}
resource "aws_s3_bucket_server_side_encryption_configuration" "s3_encryption" {
  bucket = aws_s3_bucket.bucket.id
  rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
  }
}