####################
# Subnet Validation
####################

data "aws_vpc" "default" {
  default = true
}

data "aws_subnet" "input" {
  for_each = toset(var.subnet_ids)
  id       = each.value

  lifecycle {
    postcondition {
      condition     = self.vpc_id != data.aws_vpc.default.id
      error_message = <<-EOT
      THE FOLLOWING IS PART OF THE DEFAULT VPC:

      Name= ${self.tags.Name}
      ID= ${self.id}
      
      Subnet must be in a different VPC than the default VPC.
      EOT
    }
    postcondition {
      condition     = can(lower(self.tags.Access) == "private")
      error_message = <<-EOT
      THE FOLLOWING is NOT A PRIVATE SUBNET:

      Name= ${self.tags.Name}
      ID= ${self.id}
      
      Private Subnet must have a tag name:
          Access=private
      EOT
    }
  }
}


####################
# Security Group Validation
####################

#  this 2 step process is good because it will give errors
#  when the security group has more than one rule 
data "aws_vpc_security_group_rules" "this" {
  filter {
    name   = "group-id"
    values = local.public_subnet_ids
  }
}

data "aws_vpc_security_group_rule" "this" {
  depends_on             = [aws_security_group.app_sg]
  for_each               = length(var.security_group_ids) > 0 ? toset(var.security_group_ids) : toset([])
  security_group_rule_id = each.value

  lifecycle {
    postcondition {
      condition = (
        self.is_egress ? true : self.cidr_ipv4 == null
        && self.cidr_ipv6 == null
        && self.referenced_security_group_id != null &&
        self.referenced_security_group_id == aws_security_group.rds_sg.id
      )
      error_message = <<-EOT
        The following security group contains an invalid inbound rule:
        
        ID = ${self.security_group_id}

        Please ensure that the following conditions are met:
        1. Rules must not allow inbound traffic from IP CIDR blocks, only from other security groups.

      EOT
    }
  }
}
