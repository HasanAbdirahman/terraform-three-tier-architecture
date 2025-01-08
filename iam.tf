/*
Since we created alb and asg and attached to each other
Now here we are going to create iam role for the ec2 instance
in the ASG  and iam policy permission for ALB integration

Then we are attching the role with thepolicy permission
Lastly creating an instance profile and attach it to the ASG
lAUNCH Template we created in the auto-scaling-group.tf file.
"iam_instance_profile" in the launch template resource
*/

resource "aws_iam_role" "ec2_instance_role" {
  name               = "EC2InstanceRole"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

data "aws_iam_policy_document" "assume_role" {
  version = "2012-10-17"
  statement {
    sid     = "1"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_policy" "alb_integration_policy" {
  name   = "ec2_iam_policy"
  policy = data.aws_iam_policy_document.policy.json
}


data "aws_iam_policy_document" "policy" {
  version = "2012-10-17"
  statement {
    sid    = "alb_iam_policy"
    effect = "Allow"
    actions = [
      "elasticloadbalancing:RegisterTargets",
      "elasticloadbalancing:DeregisterTargets",
      "elasticloadbalancing:DescribeTargetHealth",
      "elasticloadbalancing:DescribeLoadBalancers"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy_attachment" "attach_alb_policy" {
  role       = aws_iam_role.ec2_instance_role.id
  policy_arn = aws_iam_policy.alb_integration_policy.arn
}

resource "aws_iam_instance_profile" "profile" {
  name = "EC2InstanceProfile"
  role = aws_iam_role.ec2_instance_role.name
}


#############################################
# IAM ROLE for RDS FOR CLOUD WATCH MONITORING
###########3#################################
resource "aws_iam_role" "rds_monitoring" {
  name               = "rds_monitoring_role"
  assume_role_policy = data.aws_iam_policy_document.rds_monitoring.json
}

data "aws_iam_policy_document" "rds_monitoring" {
  version = "2012-10-17"
  statement {
    sid     = "1"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["rds.amazonaws.com"]
    }
  }
}

resource "aws_iam_policy" "rds_monitoring_policy" {
  name   = "rds_monitoring_policy"
  policy = data.aws_iam_policy_document.rds_monitoring_policy.json
}

data "aws_iam_policy_document" "rds_monitoring_policy" {
  version = "2012-10-17"
  statement {
    sid       = "1"
    effect    = "Allow"
    actions   = ["cloudwatch:GetMetricStatistics", "cloudwatch:ListMetrics", "logs:CreateLogStream", "logs:PutLogEvents"]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy_attachment" "attach_rds_monitoring_policy" {
  role       = aws_iam_role.rds_monitoring.name
  policy_arn = aws_iam_policy.rds_monitoring_policy.arn

}
