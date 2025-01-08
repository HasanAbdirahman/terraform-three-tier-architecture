# Create a load balancer
resource "aws_lb" "main" {
  name               = "demo-lb"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb_sg.id]
  subnets            = [for subnet in aws_subnet.public : subnet.id]

  # monitoring configuration
  access_logs {
    bucket  = aws_s3_bucket.lb_logs.id
    enabled = true
    prefix  = "app-lb-logs"
  }
  tags = {
    Name = "App Load Balancer"
  }
}

# Create a target group
resource "aws_lb_target_group" "test" {
  name     = "tf-example-lb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.custom_vpc.id
}


# Create a listener on port 80 with forward action
resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.test.arn
  }
}

# registering the target => we are attching the target group with 
# the instance  in this case
# resource "aws_lb_target_group_attachment" "this" {
#   for_each         = { for idx, instance in aws_instance.this : idx => instance.id }
#   target_group_arn = aws_lb_target_group.test.arn
#   target_id        = each.value
#   port             = 80
# }

resource "aws_autoscaling_attachment" "asg_attachment_bar" {
  autoscaling_group_name = aws_autoscaling_group.bar.id
  lb_target_group_arn    = aws_lb_target_group.test.arn
}

# load balance attached to the security group so that they can allow data
# to be received from the client 

resource "aws_security_group" "lb_sg" {
  name        = "lb-sg"
  description = "Allow HTTP/HTTPS traffic"
  vpc_id      = aws_vpc.custom_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
