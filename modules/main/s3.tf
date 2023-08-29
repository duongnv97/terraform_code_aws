resource "aws_s3_bucket" "s3_vpc_log_bucket" {
  bucket = "${var.master_prefix}-${var.env_prefix}-${var.app_prefix}-flow-log"
  acl    = "private"

  versioning {
    enable = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

resource "aws_s3_bucket_public_access_block" "s3_vpc_log_bucket" {
  bucket                  = aws_s3_bucket.s3_vpc_log_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
  depends_on = [
    aws_s3_bucket.s3_vpc_log_bucket
  ]
}

## static WEB
resource "aws_s3_bucket" "s3_static_web_bucket" {
  bucket = "${var.master_prefix}-${var.env_prefix}-${var.app_prefix}-flow-log"
  acl    = "private"

  versioning {
    enable = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

resource "aws_s3_bucket_public_access_block" "s3_static_web_bucket" {
  bucket                  = aws_s3_bucket.s3_vpc_log_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
  depends_on = [
    aws_s3_bucket.s3_static_web_bucket
  ]
}

data "aws_ian_policy_document" "cloudfront_policy"{
  Statement {
    action = = ["s3:GetObject"]
    resource =  ["${aws_s3_bucket.s3_static_web_bucket.arn}/*"]
    Principal {
       type = "Service"
       identifier = ["cloudfront.amazonaws.com"]
    }
    condition {
      test = "StringEquals"
      variable = "AWS:SourceArn"
      values = [aws_cloudfront_distribution.cloudfront_distribution.arn]
    }



  }
}
resource "aws_s3_bucket_policy" "cloudfront_policy" {
  bucket = aws_s3_bucket.s3_static_web_bucket.id
  policy = data.aws_ian_policy_document.cloudfront_policy.json
}