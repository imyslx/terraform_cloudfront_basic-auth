locals {
  front_bucket_name = "${var.prefix}-${var.env}-front"
  front_cloudfront_log_bucket_name = "${var.prefix}-${var.env}-front-cloundfront-log"
}

## Bucket for CloudFront

resource "aws_s3_bucket" "front" {
  bucket = local.front_bucket_name
  acl = "private"

  website {
    index_document = "index.html"
    error_document = "error.html"
  }
  cors_rule {
    allowed_headers = []
    allowed_methods = ["GET"]
    allowed_origins = ["https://${var.domains.app}"]

    expose_headers  = []
    max_age_seconds = 0
  } 

  logging {
    target_bucket = local.front_cloudfront_log_bucket_name
    target_prefix = "s3-accesslog"
  }
  tags = {
    Env  = var.env
  }
}

data "aws_iam_policy_document" "front_bucket_iam_policy" {
  statement {
    sid = "CloudFront Public S3 Access"
    effect = "Allow"
    principals {
      type = "*"
      identifiers = ["*"]
    }
    actions = ["s3:GetObject"]
    resources = ["arn:aws:s3:::${local.front_bucket_name}/*"]
    condition {
      test = "StringEquals"
      variable = "aws:UserAgent"
      values = ["Amazon CloudFront"]
    }
    condition {
      test = "StringEquals"
      variable = "aws:Referer"
      values = [ var.frontend_origin_token ]
    }
  }
}

resource "aws_s3_bucket_policy" "front_bucket_policy" {
  bucket = aws_s3_bucket.front.id
  lifecycle {
    ignore_changes = [
      policy,
    ]
  }
  policy = data.aws_iam_policy_document.front_bucket_iam_policy.json
}

## Bucket for CloudFront Log

resource "aws_s3_bucket" "front_cloudfront_log" {
  bucket = local.front_cloudfront_log_bucket_name
  acl    = "log-delivery-write"
}
