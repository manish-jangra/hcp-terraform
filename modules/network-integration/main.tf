module "peering" {
  source                       = "./peering"
  enable_cross_account_peering = var.enable_cross_account_peering
  enable_same_account_peering  = var.enable_same_account_peering
  same_account_peerings        = var.same_account_peerings
  cross_account_peerings       = var.cross_account_peerings
}

module "tgw" {
  source                      = "./tgw"
  enable_tgw                  = var.enable_tgw
  transit_gateway_attachments = var.transit_gateway_attachments
  tags                        = var.tags
}

