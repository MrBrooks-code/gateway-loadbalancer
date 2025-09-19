# Gateway Load Balancer Terraform Module

This module creates an AWS Gateway Load Balancer (GWLB) with target group, listener, and optional VPC endpoint service. It's designed to be consumed by other modules and easily connected to security appliances.

## Features

- Gateway Load Balancer with configurable settings
- Target group with health checks
- Listener for traffic forwarding
- Optional VPC endpoint service for cross-VPC connectivity
- Comprehensive health check configuration
- Access logging support
- Sticky sessions support

## Usage

### Basic Example

```hcl
module "gwlb" {
  source = "./path/to/this/module"

  name       = "security-gwlb"
  subnet_ids = ["subnet-12345", "subnet-67890"]
  vpc_id     = "vpc-abcdef123"

  tags = {
    Environment = "production"
    Team        = "security"
  }
}
```

### With VPC Endpoint Service

```hcl
module "gwlb" {
  source = "./path/to/this/module"

  name       = "security-gwlb"
  subnet_ids = ["subnet-12345", "subnet-67890"]
  vpc_id     = "vpc-abcdef123"

  create_vpc_endpoint_service     = true
  vpc_endpoint_acceptance_required = false
  vpc_endpoint_allowed_principals  = ["arn:aws:iam::123456789012:root"]

  tags = {
    Environment = "production"
    Team        = "security"
  }
}
```

### With Custom Health Checks

```hcl
module "gwlb" {
  source = "./path/to/this/module"

  name       = "security-gwlb"
  subnet_ids = ["subnet-12345", "subnet-67890"]
  vpc_id     = "vpc-abcdef123"

  health_check_protocol           = "HTTP"
  health_check_path              = "/health"
  health_check_port              = "8080"
  health_check_interval          = 15
  health_check_healthy_threshold = 2

  tags = {
    Environment = "production"
    Team        = "security"
  }
}
```

## Connecting Appliances

After creating the GWLB, you can attach security appliances using target group attachments:

```hcl
# Use the module
module "gwlb" {
  source = "./path/to/this/module"
  # ... configuration
}

# Attach EC2 instances to the target group
resource "aws_lb_target_group_attachment" "appliance" {
  count            = length(var.appliance_instance_ids)
  target_group_arn = module.gwlb.target_group_arn
  target_id        = var.appliance_instance_ids[count.index]
  port             = 6081
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| aws | >= 4.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | Name of the Gateway Load Balancer | `string` | n/a | yes |
| subnet_ids | List of subnet IDs to attach to the Gateway Load Balancer | `list(string)` | n/a | yes |
| vpc_id | VPC ID where the target group will be created | `string` | n/a | yes |
| enable_deletion_protection | Enable deletion protection for the Gateway Load Balancer | `bool` | `false` | no |
| target_group_port | Port on which targets receive traffic from the load balancer | `number` | `6081` | no |
| target_type | Type of target that you must specify when registering targets | `string` | `"instance"` | no |
| health_check_enabled | Whether health checks are enabled | `bool` | `true` | no |
| health_check_healthy_threshold | Number of consecutive health checks successes required | `number` | `3` | no |
| health_check_interval | Approximate amount of time, in seconds, between health checks | `number` | `30` | no |
| health_check_matcher | Response codes to use when checking for healthy responses | `string` | `null` | no |
| health_check_path | Destination for the health check request | `string` | `"/"` | no |
| health_check_port | Port to use to connect with the target for health checking | `string` | `"traffic-port"` | no |
| health_check_protocol | Protocol to use to connect with the target for health checking | `string` | `"TCP"` | no |
| health_check_timeout | Amount of time, in seconds, during which no response means failed health check | `number` | `5` | no |
| health_check_unhealthy_threshold | Number of consecutive health check failures required | `number` | `3` | no |
| stickiness_enabled | Whether to enable sticky sessions | `bool` | `false` | no |
| access_logs_enabled | Whether to enable access logs | `bool` | `false` | no |
| access_logs_bucket | S3 bucket name to store access logs | `string` | `null` | no |
| access_logs_prefix | S3 bucket prefix for access logs | `string` | `null` | no |
| create_vpc_endpoint_service | Whether to create a VPC endpoint service | `bool` | `false` | no |
| vpc_endpoint_acceptance_required | Whether acceptance is required for the VPC endpoint service | `bool` | `false` | no |
| vpc_endpoint_allowed_principals | List of principals allowed to discover the VPC endpoint service | `list(string)` | `[]` | no |
| tags | A map of tags to assign to the resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| gwlb_arn | ARN of the Gateway Load Balancer |
| gwlb_arn_suffix | ARN suffix for use with CloudWatch Metrics |
| gwlb_dns_name | DNS name of the Gateway Load Balancer |
| gwlb_zone_id | Canonical hosted zone ID of the Gateway Load Balancer |
| target_group_arn | ARN of the target group |
| target_group_arn_suffix | ARN suffix for use with CloudWatch Metrics |
| listener_arn | ARN of the listener |
| vpc_endpoint_service_arn | ARN of the VPC endpoint service (if created) |
| vpc_endpoint_service_name | Service name of the VPC endpoint service (if created) |
| vpc_endpoint_service_id | ID of the VPC endpoint service (if created) |