locals {
  db_engine = {
    postgres-latest = {
      engine  = "postgres"
      version = "16.1"
      family  = "postgres16"
    }
    postgres-14 = {
      engine  = "postgres"
      version = "14.11"
      family  = "postgres14"
    }
  }
  # Get the subnet IDs for private subnets
  private_subnet_ids = [for subnet in aws_subnet.private : subnet.id]

  # Get the subnet IDs for public subnets
  public_subnet_ids = [for subnet in aws_subnet.public : subnet.id]

  # Get security group IDs
  security_group_ids = [aws_security_group.app_sg.id]
}


resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "rds-private-subnet-group"
  subnet_ids = local.private_subnet_ids

  tags = {
    Name = "RDS Private Subnet Group"
  }
}

resource "aws_db_instance" "default" {
  allocated_storage      = var.storage_size
  db_name                = var.project_name
  engine_version         = local.db_engine[var.engine].version
  instance_class         = var.instance_class
  username               = var.credentials.username
  password               = var.credentials.password
  parameter_group_name   = "default.postgres14"
  skip_final_snapshot    = true
  publicly_accessible    = false
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids = local.security_group_ids

# Enable storage encryption
  storage_encrypted      = true
#  KMS key for encryption
  kms_key_id             = var.kms_key_id

  # Enable CloudWatch logs export
  enabled_cloudwatch_logs_exports = [
    "error",    # Export error logs
    "general",  # Export general logs
    "slowquery" # Export slow query logs
  ]
  # Attach the IAM role to allow CloudWatch Logs exports
  monitoring_role_arn = aws_iam_role.rds_monitoring.arn

  tags = {
    Name = "${var.project_name}-rds"
  }
}

resource "aws_security_group" "rds_sg" {
  name        = "rds-sg"
  description = "Allow traffic from Application SG"
  vpc_id      = aws_vpc.custom_vpc.id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.app_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
