output "vpc_peering_connections" {
  value = var.enable_same_account_peering ? aws_vpc_peering_connection.same_account_same_region : {}
}

output "cross_account_vpc_peering_connections" {
  value = var.enable_cross_account_peering ? aws_vpc_peering_connection.different_account_same_region : {}
}
