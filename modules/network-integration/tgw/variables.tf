variable "enable_tgw" {
  type    = bool
  default = false
}

variable "tags" {
  type    = map(string)
  default = {}
}

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
