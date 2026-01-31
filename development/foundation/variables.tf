variable "default_tags" {
  type = map(string)
  default = {
    "project"       = "Konflux"
    "owner"         = "konflux-infra@redhat.com"
    "app-code"      = "ASSH-001",
    "service-phase" = "production",
    "cost-center"   = "670"
  }
}

variable "cluster_name" {
  type = string
  default = "hcp-development"
}

variable "cluster_vpc_cidr" {
  type = string
  default = "10.0.0.0/16"
}

variable "cluster_private_subnets" {
    type = list(string)
    default = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "cluster_public_subnets" {
    type = list(string)
    default = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
}

variable "database_vpc_cidr" {
    type = string
    default = "10.1.0.0/16"
}

variable "database_subnets" {
    type = list(string)
    default = ["10.1.1.0/24", "10.1.2.0/24", "10.1.3.0/24"]
}

variable "mpc_vpc_cidr" {
    type = string
    default = "10.2.0.0/16"
}

variable "mpc_private_subnets" {
    type = list(string)
    default = ["10.2.1.0/24", "10.2.2.0/24", "10.2.3.0/24"]
}

variable "mpc_public_subnets" {
    type = list(string)
    default = ["10.2.101.0/24", "10.2.102.0/24", "10.2.103.0/24"]
}

variable "secondary_cidr_blocks" {
    type = list(string)
    default = ["10.3.0.0/16", "10.4.0.0/16"]
}

variable "environment_type" {
    type = string
    default = "public"
}
