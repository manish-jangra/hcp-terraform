# [ VPC Peering ] --- Route Table Update for ROSA && Database VPC Peering ---

# --- ROSA to Database ---
resource "aws_route" "rosa_to_database" {
  for_each                  = var.update_routes ? var.routes_configuration : {}
  route_table_id            = each.value.route_table_id
  destination_cidr_block    = each.value.destination_cidr_block
  vpc_peering_connection_id = try(each.value.vpc_peering_connection_id, null)
  transit_gateway_id        = try(each.value.transit_gateway_id, null)
}

variable "update_routes" {
  type    = bool
  default = true
}

variable "routes_configuration" {
  type = map(object({
    route_table_id            = string
    destination_cidr_block    = string
    vpc_peering_connection_id = string
    transit_gateway_id        = string
  }))
}
