# /*
# This page was dedicated on testing the load balancer and 
# use it a target group but now we have auto scaling group
# */

# locals {
#   project_name  = "three-tier-project"
#   instance_type = "t2.micro"
# }

# resource "aws_instance" "this" {
#   count         = 2
#   instance_type = local.instance_type
#   ami           = data.aws_ami.ubuntu.id
#   subnet_id     = aws_subnet.private[count.index % length(aws_subnet.private)].id
#   tags = {
#     Name    = "${local.project_name}-${count.index}"
#     Project = local.project_name
#   }
# }
