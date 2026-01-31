terraform {
  required_version = ">= 1.2"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.0.0"
    }
  }
}

provider "aws" {
  region = "ap-south-1"
}

provider "aws" {
  region = "ap-south-1"
  alias = "multi_platform_account"
}
