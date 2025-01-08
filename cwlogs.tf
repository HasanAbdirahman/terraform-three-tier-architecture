# log for rds
resource "aws_cloudwatch_log_group" "rds_log_group" {
  name              = "/aws/rds/instance/${aws_db_instance.default.id}/logs"
  retention_in_days = 30
}
