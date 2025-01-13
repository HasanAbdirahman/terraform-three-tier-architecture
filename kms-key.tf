resource "aws_kms_key" "rds_key" {
  description             = "KMS key for RDS storage encryption"
  key_usage               = "ENCRYPT_DECRYPT"
  customer_master_key_spec = "SYMMETRIC_DEFAULT"

  tags = {
    Name = "rds-encryption-key"
  }
}

resource "aws_kms_alias" "rds_key_alias" {
  name          = "alias/rds-encryption-key"
  target_key_id = aws_kms_key.rds_key.id
}
