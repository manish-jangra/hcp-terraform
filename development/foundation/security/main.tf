module "security_groups" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.3.0"

  for_each = var.security_groups

  name                     = each.value.name
  description              = "Security group for user-service with custom ports open within VPC, and PostgreSQL publicly open"
  vpc_id                   = var.vpc_id
  ingress_cidr_blocks      = each.value.ingress_cidr_blocks
  ingress_rules            = each.value.ingress_rules
  ingress_with_cidr_blocks = each.value.ingress_with_cidr_blocks
}

variable "security_groups" {
  type = map(object({
    name                = string
    description         = string
    ingress_cidr_blocks = list(string)
    ingress_rules       = list(string)
    ingress_with_cidr_blocks = list(object({
      from_port = number
      to_port   = number
      protocol  = string
    }))
  }))
}

variable "vpc_id" {
  type = string
}

output "security_groups" {
  value = module.security_groups
}

# IAM

# KMS
