variable "enable_cross_account_peering" {
  type    = bool
  default = false
}

variable "enable_same_account_peering" {
  type    = bool
  default = true
}

variable "same_account_peerings" {
  type = map(object({
    name        = string
    vpc_id      = string
    peer_vpc_id = string
  }))
}

variable "cross_account_peerings" {
  type = map(object({
    name          = string
    vpc_id        = string
    peer_vpc_id   = string
    peer_owner_id = string
    peer_region   = string
  }))
}

# variable "update_routes" {
#   type    = bool
#   default = true
# }

# variable "routes_configuration" {
#   type = map(object({
#     route_table_id            = string
#     destination_cidr_block    = string
#     vpc_peering_connection_id = string
#     transit_gateway_id        = string
#   }))
# }

variable "transit_gateway_attachments" {
  type = map(object({
    transit_gateway_id = string
    vpc_id             = string
    subnet_ids         = list(string)
    use_accepter       = bool
    name               = optional(string)
    tags               = optional(map(string))
  }))
  default = {}
}

variable "enable_tgw" {
  type    = bool
  default = false
}

variable "tags" {
  type    = map(string)
  default = {}
}
