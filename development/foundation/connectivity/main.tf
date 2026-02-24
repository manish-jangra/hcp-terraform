module "connectivity" {
    source = "../../../modules/network-integration"

    enable_tgw = true
    enable_same_account_peering = true
    enable_cross_account_peering = false
    tags       = var.default_tags

    transit_gateway_attachments = {
        cluster = {
            transit_gateway_id = var.transit_gateway_id
            vpc_id             = data.terraform_remote_state.network.outputs.vpcs["cluster"].vpc_id
            subnet_ids         = data.terraform_remote_state.network.outputs.vpcs["cluster"].private_subnets
            use_accepter       = false
            name               = "tgw-attach-cluster"
        }
        database = {
            transit_gateway_id = var.transit_gateway_id
            vpc_id             = data.terraform_remote_state.network.outputs.vpcs["database"].vpc_id
            subnet_ids         = data.terraform_remote_state.network.outputs.vpcs["database"].private_subnets
            use_accepter       = false
            name               = "tgw-attach-database"
        }
    }
    same_account_peerings = {
        cluster = {
            name        = "cluster-to-database"
            vpc_id      = data.terraform_remote_state.network.outputs.vpcs["cluster"].vpc_id
            peer_vpc_id = data.terraform_remote_state.network.outputs.vpcs["database"].vpc_id
        }
    }
}

variable "default_tags" {
    type = map(string)
    default = {
        "project" = "Konflux"
        "owner" = "konflux-infra@redhat.com"
        "app-code" = "ASSH-001"
        "service-phase" = "production"
        "cost-center" = "670"
    }
}

variable "transit_gateway_id" {
    type = string
    default = "tgw-01234567890123456"
}

data "terraform_remote_state" "network" {
    backend = "local"
    config = {
        path = "../network/terraform.tfstate"
    }
}
