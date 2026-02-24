resource "aws_ec2_transit_gateway_vpc_attachment" "this" {
  for_each = var.enable_tgw ? var.transit_gateway_attachments : {}

  provider           = each.value.use_accepter ? aws.accepter : aws
  transit_gateway_id = each.value.transit_gateway_id
  vpc_id             = each.value.vpc_id
  subnet_ids         = tolist(each.value.subnet_ids)

  tags = merge(
    var.tags,
    coalesce(each.value.tags, {}),
    {
      Name = coalesce(each.value.name, "tgw-attachment-${each.key}")
    }
  )
}
