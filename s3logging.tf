resource "aws_s3_bucket" "lb_logs" {
  bucket        = "my-app-lb-logs"
  force_destroy = true
}

