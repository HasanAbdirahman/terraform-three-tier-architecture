
data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-*-22.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_placement_group" "test" {
  name     = "placement_group_test"
  strategy = "cluster"
}

# launch template 
resource "aws_launch_template" "foobar" {
  name_prefix   = "launch_template"
  image_id      = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"

  iam_instance_profile {
    name = aws_iam_instance_profile.profile.name
  }

  block_device_mappings {
    device_name = "demo_instance"
    ebs {
      volume_size = 10
    }
  }
}


resource "aws_autoscaling_group" "bar" {
  desired_capacity  = 1
  max_size          = 2
  min_size          = 1
  health_check_type = "ELB"
  placement_group   = aws_placement_group.test.id
  #   list of subnets id - Attach the ASG to private subnets
  vpc_zone_identifier = [for subnet in aws_subnet.private : subnet.id]

  initial_lifecycle_hook {
    name                 = "foobar"
    heartbeat_timeout    = 2000
    lifecycle_transition = "autoscaling:EC2_INSTANCE_LAUNCHING"
    default_result       = "CONTINUE"
  }


  launch_template {
    id      = aws_launch_template.foobar.id
    version = "$Latest"
  }
}


# asg load balncer 
resource "aws_security_group" "app_sg" {
  name        = "app-sg"
  description = "Allow traffic from ALB"
  vpc_id      = aws_vpc.custom_vpc.id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.lb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
