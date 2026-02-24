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
