output "gwlb_arn" {
  description = "ARN of the Gateway Load Balancer"
  value       = aws_lb.gwlb.arn
}

output "gwlb_arn_suffix" {
  description = "ARN suffix for use with CloudWatch Metrics"
  value       = aws_lb.gwlb.arn_suffix
}

output "gwlb_dns_name" {
  description = "DNS name of the Gateway Load Balancer"
  value       = aws_lb.gwlb.dns_name
}

output "gwlb_zone_id" {
  description = "Canonical hosted zone ID of the Gateway Load Balancer"
  value       = aws_lb.gwlb.zone_id
}

output "target_group_arn" {
  description = "ARN of the target group"
  value       = aws_lb_target_group.gwlb.arn
}

output "target_group_arn_suffix" {
  description = "ARN suffix for use with CloudWatch Metrics"
  value       = aws_lb_target_group.gwlb.arn_suffix
}

output "listener_arn" {
  description = "ARN of the listener"
  value       = aws_lb_listener.gwlb.arn
}

output "vpc_endpoint_service_arn" {
  description = "ARN of the VPC endpoint service (if created)"
  value       = module.endpoint.vpc_endpoint_service_arn
}

output "vpc_endpoint_service_name" {
  description = "Service name of the VPC endpoint service (if created)"
  value       = module.endpoint.vpc_endpoint_service_name
}

output "vpc_endpoint_service_id" {
  description = "ID of the VPC endpoint service (if created)"
  value       = module.endpoint.vpc_endpoint_service_id
}

output "vpc_endpoint_service_state" {
  description = "State of the VPC endpoint service (if created)"
  value       = module.endpoint.vpc_endpoint_service_state
}

output "vpc_endpoint_service_base_endpoint_dns_names" {
  description = "Base endpoint DNS names of the VPC endpoint service (if created)"
  value       = module.endpoint.vpc_endpoint_service_base_endpoint_dns_names
}

output "vpc_endpoints" {
  description = "Map of VPC endpoint details"
  value       = module.endpoint.vpc_endpoints
}

output "vpc_endpoint_ids" {
  description = "List of VPC endpoint IDs"
  value       = module.endpoint.vpc_endpoint_ids
}

output "vpc_endpoint_arns" {
  description = "List of VPC endpoint ARNs"
  value       = module.endpoint.vpc_endpoint_arns
}

output "vpc_endpoint_dns_entries" {
  description = "List of VPC endpoint DNS entries"
  value       = module.endpoint.vpc_endpoint_dns_entries
}

output "vpc_endpoint_network_interface_ids" {
  description = "List of network interface IDs for VPC endpoints"
  value       = module.endpoint.vpc_endpoint_network_interface_ids
}

# S3 Logging Outputs
output "access_logs_bucket_id" {
  description = "ID of the S3 bucket for access logs (automatically created)"
  value       = module.s3_access_logs.bucket_id
}

output "connection_logs_bucket_id" {
  description = "ID of the S3 bucket for connection logs (automatically created)"
  value       = module.s3_connection_logs.bucket_id
}