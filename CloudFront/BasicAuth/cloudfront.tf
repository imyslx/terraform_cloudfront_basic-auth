
resource "aws_cloudfront_distribution" "distribution" {
  default_cache_behavior {
    function_association {
      event_type   = "viewer-request"
      function_arn = aws_cloudfront_function.basic_auth.arn
    }
  }
}

resource "aws_cloudfront_function" "basic_auth" {
  name    = "basic_auth"
  runtime = "cloudfront-js-1.0"
  comment = "for basic authorization"
  publish = true
  code    = templatefile("${path.module}/code/function.js", { basic_string = base64encode("${var.basic_user}:${var.basic_pass}") })
}
