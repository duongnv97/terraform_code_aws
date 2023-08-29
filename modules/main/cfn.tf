locals {
    s3_origin_id = "access-identity-s3"
}
resource "aws_cloudfront_origin_access_control" "oac" {
  name                  = format("%s-%s", local.general_prefix, "oac")
  description           = "Origin Access Control"
  origin_access_control_origin_type = "s3"
  signing_behavior      = "always"
  signing_protocol      = "sigv4"
}
resource "aws_cloudfront_distribution" "cloudfront_distribution" {
  origin {
    domain_name = aws_s3_bucket.s3_static_web_bucket.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.oac.id
    origin_id   = local.s3_origin_id
  }

  enabled             = true
  is_ipv6_enabled     = true


  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    compress               = true
    min_ttl                = 1
    default_ttl            = 86400
    max_ttl                = 31536000
  }
    
 viewer_certificate {
    cloudfront_deffault_certificate = true
 }
 http_version = "http2and3"
 price_class = "PriceClass_All"
}