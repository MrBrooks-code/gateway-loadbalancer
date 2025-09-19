output "vpc_endpoint_service_arn" {
  description = "ARN of the VPC endpoint service (if created)"
  value       = var.create_vpc_endpoint_service ? aws_vpc_endpoint_service.gwlb[0].arn : null
}

output "vpc_endpoint_service_name" {
  description = "Service name of the VPC endpoint service (if created)"
  value       = var.create_vpc_endpoint_service ? aws_vpc_endpoint_service.gwlb[0].service_name : null
}

output "vpc_endpoint_service_id" {
  description = "ID of the VPC endpoint service (if created)"
  value       = var.create_vpc_endpoint_service ? aws_vpc_endpoint_service.gwlb[0].id : null
}

output "vpc_endpoint_service_state" {
  description = "State of the VPC endpoint service (if created)"
  value       = var.create_vpc_endpoint_service ? aws_vpc_endpoint_service.gwlb[0].state : null
}

output "vpc_endpoint_service_base_endpoint_dns_names" {
  description = "Base endpoint DNS names of the VPC endpoint service (if created)"
  value       = var.create_vpc_endpoint_service ? aws_vpc_endpoint_service.gwlb[0].base_endpoint_dns_names : []
}

output "vpc_endpoints" {
  description = "Map of VPC endpoint details"
  value = {
    for idx, endpoint in aws_vpc_endpoint.gwlb : var.vpc_endpoint_configs[idx].name => {
      id                    = endpoint.id
      arn                   = endpoint.arn
      state                 = endpoint.state
      dns_entry             = endpoint.dns_entry
      network_interface_ids = endpoint.network_interface_ids
      owner_id              = endpoint.owner_id
      creation_timestamp    = endpoint.creation_timestamp
    }
  }
}

output "vpc_endpoint_ids" {
  description = "List of VPC endpoint IDs"
  value       = aws_vpc_endpoint.gwlb[*].id
}

output "vpc_endpoint_arns" {
  description = "List of VPC endpoint ARNs"
  value       = aws_vpc_endpoint.gwlb[*].arn
}

output "vpc_endpoint_dns_entries" {
  description = "List of VPC endpoint DNS entries"
  value       = aws_vpc_endpoint.gwlb[*].dns_entry
}

output "vpc_endpoint_network_interface_ids" {
  description = "List of network interface IDs for VPC endpoints"
  value       = aws_vpc_endpoint.gwlb[*].network_interface_ids
}