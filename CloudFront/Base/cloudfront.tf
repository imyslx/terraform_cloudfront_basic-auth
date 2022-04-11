
resource "aws_cloudfront_distribution" "front_distribution" {
  origin {
    domain_name = aws_s3_bucket.front.website_endpoint
    origin_id   = aws_s3_bucket.front.bucket_regional_domain_name
    origin_path = ""
    custom_header {
      name = "Referer"
      value = var.frontend_origin_token
    }
    custom_origin_config {
      origin_protocol_policy = "http-only"
      http_port              = 80
      https_port             = 443
      origin_ssl_protocols   = ["TLSv1.2", "TLSv1.1", "TLSv1"]
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "Distribute web"

  logging_config {
    include_cookies = false
    bucket          = aws_s3_bucket.front_cloudfront_log.bucket_regional_domain_name
    prefix          = "cloudfront-accesslog"
  }

  aliases = [
    var.domains.app
  ]

  default_root_object = "index.html"
  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = aws_s3_bucket.front.bucket_regional_domain_name
    compress = true
    forwarded_values {
      query_string = false
      headers      = ["Origin"]
      cookies {
        forward = "none"
      }
    }
    viewer_protocol_policy = "redirect-to-https"
    default_ttl = 0
    max_ttl = 0
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
  tags = {
    Env  = var.env
  }

  viewer_certificate {
    ssl_support_method = "sni-only"
    acm_certificate_arn = var.front_acm_arn
    minimum_protocol_version = "TLSv1"
  }
  custom_error_response {
      error_caching_min_ttl = 300
      error_code = 404
      response_code = 200
      response_page_path = "/index.html"
  }
}
