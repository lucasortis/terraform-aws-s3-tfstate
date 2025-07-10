resource "random_string" "random_suffix" {
  length  = 8
  upper   = false
  special = false
}

resource "aws_s3_bucket" "remote_backend" {
  bucket        = "lortis-${random_string.random_suffix.result}-${var.environment}"
  force_destroy = true
  tags = {
    Name        = "TF Backend for Crisis Text Line Assessment"
    Environment = var.environment
  }
}

resource "aws_s3_bucket_ownership_controls" "remote_backend" {
  bucket = aws_s3_bucket.remote_backend.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "remote_backend" {
  bucket     = aws_s3_bucket.remote_backend.id
  acl        = "private"
  depends_on = [aws_s3_bucket_ownership_controls.remote_backend]
}

resource "aws_s3_bucket_versioning" "remote_backend" {
  bucket = aws_s3_bucket.remote_backend.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "remote_backend" {
  bucket = aws_s3_bucket.remote_backend.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# This policy ensures that the bucket can only be accessed over HTTPS.
# It denies any requests that are not using secure transport.
resource "aws_s3_bucket_policy" "remote_backend" {
  bucket = aws_s3_bucket.remote_backend.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "EnforcedTLS"
        Effect = "Deny"
        Action = "s3:*"
        Resource = [
          "${aws_s3_bucket.remote_backend.arn}",
          "${aws_s3_bucket.remote_backend.arn}/*"
        ]
        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
        Principal = "*"
      }
    ]
  })
}

# This resource configures the S3 bucket for object lock.
# DynamoDB-based locking is deprecated and is going to be discontinued in the future, it is recommended to use S3 Object Lock configuration instead.
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_object_lock_configuration
resource "aws_s3_bucket_object_lock_configuration" "remote_backend" {
  depends_on = [aws_s3_bucket_versioning.remote_backend]
  bucket     = aws_s3_bucket.remote_backend.id
}
