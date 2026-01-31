// RDS Database for Konflux UI / Kite

data "terraform_remote_state" "foundation" {
  backend = "remote"
  config = {
    organization = "konflux_infrastructure"
    workspaces = {
      name = "foundation"
    }
  }
}

resource "random_password" "db_pass" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

data "aws_caller_identity" "current" {
}

resource "aws_security_group" "database_security_group" {
  name        = "allow-traffic-to-rds-database"
  description = "Allow inbound traffic from ROSA Cluster"
  vpc_id      = data.terraform_remote_state.foundation.outputs.vpcs.database.vpc_id
  tags = {
    Name = "RDS Database Security Group"
  }
}

resource "aws_kms_key" "database_kms_key" {
  description = "Symmetric encryption KMS key for RDS Database"
  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "rds-database-kms-key-policy"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        },
        Action   = "kms:*"
        Resource = "*"
      }
    ]
  })
  tags = {
    Name = "Database KMS Key"
  }
}

// Terraform Module for RDS DB
// https://registry.terraform.io/modules/terraform-aws-modules/rds/aws

module "database" {
  source  = "terraform-aws-modules/rds/aws"
  version = "6.11.0"

  identifier                  = "hcp-terraform"
  engine                      = "postgres"
  engine_version              = "16.10"
  instance_class              = "db.m6g.large"
  allocated_storage           = 20  #30
  max_allocated_storage       = 100 #500
  storage_type                = "gp3"
  storage_encrypted           = true
  deletion_protection         = true
  backup_retention_period     = 30
  kms_key_id                  = aws_kms_key.database_kms_key.arn
  manage_master_user_password = false
  db_subnet_group_name        = data.terraform_remote_state.foundation.outputs.vpcs.database.database_subnet_group_name
  family                      = "postgres16"
  # Database Engine specific parameters - https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Appendix.PostgreSQL.CommonDBATasks.Parameters.html
  parameters = [
    {
      name  = "default_statistics_target"
      value = 2000
    },
    {
      name  = "random_page_cost"
      value = 2
    }
  ]
  db_name                      = "hcp_terraform"
  username                     = "hcp_terraform"
  password                     = sensitive(random_password.db_pass.result)
  vpc_security_group_ids       = [ aws_security_group.database_security_group.id ]
  maintenance_window           = "fri:10:00-fri:14:00"
  multi_az                     = true
  auto_minor_version_upgrade   = false
  allow_major_version_upgrade  = true
  performance_insights_enabled = true
  ca_cert_identifier           = "rds-ca-rsa2048-g1"
  apply_immediately            = true
}
