# outputs.tf

output "vpcs" {
  description = "A unified map of all provisioned networks"
  value = {
    # Primary account VPCs
    "cluster"  = module.primary_vpcs["cluster"]
    "database" = module.primary_vpcs["database"]
    
    # Multi-platform account VPC
    "multi_platform" = module.multi_platform_vpc
  }
}
