# --- Cluster VPC and Database VPC Peering Configuration ---
# This configuration establishes a peering connection between the Cluster VPC and the Database VPC.
# Key points:
# 1. Internal IP addresses are not used for the Database VPC, as it only communicates with the ROSA Cluster.
# 2. Both VPCs will always be peered, and their route tables will be updated accordingly.
# 3. Typically, the Database VPC and the Cluster VPC reside in the same AWS account and region.

resource "aws_vpc_peering_connection" "same_account_same_region" {
  for_each    = var.enable_same_account_peering ? var.same_account_peerings : {}
  vpc_id      = each.value.vpc_id
  peer_vpc_id = each.value.peer_vpc_id

  auto_accept = true

  tags = {
    Name = each.value.name
  }
}

# --> Different Account Same Region or Different Region
resource "aws_vpc_peering_connection" "different_account_same_region" {
  for_each = var.enable_cross_account_peering ? var.cross_account_peerings : {}

  vpc_id        = each.value.vpc_id
  peer_vpc_id   = each.value.peer_vpc_id
  peer_owner_id = each.value.peer_owner_id
  auto_accept   = false

  tags = {
    Name = each.value.name
  }
}

resource "aws_vpc_peering_connection_accepter" "different_account_same_region" {
  for_each = var.enable_cross_account_peering ? var.cross_account_peerings : {}

  provider                  = aws.accepter
  vpc_peering_connection_id = aws_vpc_peering_connection.different_account_same_region[each.key].id
  auto_accept               = true
  tags = {
    Name = "${each.value.vpc_id}-to-${each.value.peer_vpc_id}-peering"
  }
}

resource "aws_vpc_peering_connection_options" "requester" {
  for_each = var.enable_cross_account_peering ? var.cross_account_peerings : {}

  vpc_peering_connection_id = aws_vpc_peering_connection_accepter.different_account_same_region[each.key].id
  requester {
    allow_remote_vpc_dns_resolution = true
  }
}

resource "aws_vpc_peering_connection_options" "accepter" {
  for_each = var.enable_cross_account_peering ? var.cross_account_peerings : {}

  provider                  = aws.accepter
  vpc_peering_connection_id = aws_vpc_peering_connection_accepter.different_account_same_region[each.key].id
  accepter {
    allow_remote_vpc_dns_resolution = true
  }
}

variable "peerings" {
  type = map(object({
    vpc_id        = string
    peer_vpc_id   = string
    peer_owner_id = optional(string)
    use_accepter  = bool
    auto_accept   = optional(bool)
    name          = optional(string)
    tags          = optional(map(string))
  }))
  default = {}
}
