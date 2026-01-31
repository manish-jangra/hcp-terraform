data "aws_availability_zones" "azs" {
  state = "available"
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

# locals.tf
locals {
  # Configuration for VPCs sharing the primary AWS provider
  primary_vpc_configs = {
    "cluster" = {
      name                 = "${var.cluster_name}-rosa"
      cidr                 = var.cluster_vpc_cidr
      private_subnets      = var.cluster_private_subnets
      public_subnets       = var.cluster_public_subnets
      enable_nat_gateway   = true
      single_nat_gateway   = false
      one_nat_gateway_per_az = true
    }
    "database" = {
      name                           = "${var.cluster_name}-database"
      cidr                           = var.database_vpc_cidr
      database_subnets               = var.database_subnets
      enable_nat_gateway             = false
      create_database_subnet_group   = true
      create_database_subnet_route_table = true
    }
  }
}

# vpc.tf

# DATA: Get AZs for both accounts
data "aws_availability_zones" "primary_azs" {
  state = "available"
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

data "aws_availability_zones" "mp_account_azs" {
  provider = aws.multi_platform_account
  state    = "available"
}

# BLOCK 1: Consolidated loop for Cluster and Database VPCs
module "primary_vpcs" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "6.6.0"

  for_each = local.primary_vpc_configs

  name = each.value.name
  cidr = each.value.cidr
  azs  = slice(data.aws_availability_zones.primary_azs.names, 0, 3)

  private_subnets = lookup(each.value, "private_subnets", [])
  public_subnets  = lookup(each.value, "public_subnets", [])

  # Database-specific attributes
  database_subnets                   = try(each.value.database_subnets, [])
  create_database_subnet_group       = try(each.value.create_database_subnet_group, false)
  create_database_subnet_route_table = try(each.value.create_database_subnet_route_table, false)

  # NAT Gateway Strategy
  enable_nat_gateway     = lookup(each.value, "enable_nat_gateway", false)
  single_nat_gateway     = lookup(each.value, "single_nat_gateway", true)
  one_nat_gateway_per_az = lookup(each.value, "one_nat_gateway_per_az", false)

  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = var.default_tags
}

# BLOCK 2: Standalone module for Multi-Platform (Supports cross-account provider)
module "multi_platform_vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "6.6.0"

  providers = {
    aws = aws.multi_platform_account
  }

  name                  = "multi-platform-build"
  cidr                  = var.mpc_vpc_cidr
  secondary_cidr_blocks = var.secondary_cidr_blocks
  azs                   = slice(data.aws_availability_zones.mp_account_azs.names, 0, 1)

  # Logic: Private environments use MPC VPC CIDR directly
  private_subnets = var.environment_type == "private" ? [var.mpc_vpc_cidr] : var.mpc_private_subnets
  public_subnets  = var.environment_type == "private" ? var.secondary_cidr_blocks : var.mpc_public_subnets

  enable_nat_gateway   = true
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = var.default_tags
}
