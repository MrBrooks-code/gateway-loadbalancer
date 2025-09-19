resource "aws_vpc_endpoint_service" "gwlb" {
  count = var.create_vpc_endpoint_service ? 1 : 0

  acceptance_required        = var.vpc_endpoint_acceptance_required
  gateway_load_balancer_arns = var.gateway_load_balancer_arns
  allowed_principals         = var.vpc_endpoint_allowed_principals

  tags = var.tags
}

# VPC Endpoint for consumers in other VPCs
resource "aws_vpc_endpoint" "gwlb" {
  count = length(var.vpc_endpoint_configs)

  vpc_id              = var.vpc_endpoint_configs[count.index].vpc_id
  service_name        = aws_vpc_endpoint_service.gwlb[0].service_name
  vpc_endpoint_type   = "GatewayLoadBalancer"
  subnet_ids          = var.vpc_endpoint_configs[count.index].subnet_ids
  security_group_ids  = var.vpc_endpoint_configs[count.index].security_group_ids
  private_dns_enabled = var.vpc_endpoint_configs[count.index].private_dns_enabled
  auto_accept         = var.vpc_endpoint_configs[count.index].auto_accept


  timeouts {
    create = var.vpc_endpoint_create_timeout
    update = var.vpc_endpoint_update_timeout
    delete = var.vpc_endpoint_delete_timeout
  }

  tags = merge(
    var.tags,
    var.vpc_endpoint_configs[count.index].tags,
    {
      Name = "${var.vpc_endpoint_configs[count.index].name}-gwlb-endpoint"
    }
  )
}