# Gateway Load Balancer Endpoint Submodule

This submodule manages VPC endpoint services and VPC endpoints for Gateway Load Balancer cross-VPC connectivity.

## Features

- **VPC Endpoint Service**: Exposes the Gateway Load Balancer as a service that can be consumed across VPCs
- **VPC Endpoints**: Creates consumer endpoints in multiple VPCs to connect to the GWLB service
- **Flexible Configuration**: Supports multiple endpoint configurations with individual settings
- **Security Integration**: Supports security groups and IAM policies per endpoint
- **Auto-acceptance**: Configurable automatic acceptance of endpoint connections

## Usage

### Basic VPC Endpoint Service

```hcl
module "gwlb_endpoint" {
  source = "./endpoint"

  create_vpc_endpoint_service      = true
  vpc_endpoint_acceptance_required = false
  gateway_load_balancer_arns       = [aws_lb.gwlb.arn]
  vpc_endpoint_allowed_principals  = ["arn:aws:iam::123456789012:root"]

  tags = {
    Environment = "production"
    Component   = "security"
  }
}
```

### Multiple VPC Endpoints

```hcl
module "gwlb_endpoint" {
  source = "./endpoint"

  create_vpc_endpoint_service = true
  gateway_load_balancer_arns  = [aws_lb.gwlb.arn]

  vpc_endpoint_configs = [
    {
      name       = "prod-web-tier"
      vpc_id     = "vpc-12345678"
      subnet_ids = ["subnet-12345", "subnet-67890"]
      security_group_ids = ["sg-web123"]
      auto_accept = true
      tags = {
        Tier = "web"
      }
    },
    {
      name       = "prod-app-tier"
      vpc_id     = "vpc-87654321"
      subnet_ids = ["subnet-abcde", "subnet-fghij"]
      security_group_ids = ["sg-app456"]
      auto_accept = true
      policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
          {
            Effect = "Allow"
            Principal = "*"
            Action = [
              "elasticloadbalancing:*"
            ]
            Resource = "*"
          }
        ]
      })
      tags = {
        Tier = "application"
      }
    }
  ]

  tags = {
    Environment = "production"
  }
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
| create_vpc_endpoint_service | Whether to create a VPC endpoint service | `bool` | `false` | no |
| vpc_endpoint_acceptance_required | Whether acceptance is required for the VPC endpoint service | `bool` | `false` | no |
| gateway_load_balancer_arns | List of Gateway Load Balancer ARNs | `list(string)` | n/a | yes |
| vpc_endpoint_allowed_principals | List of principals allowed to discover the service | `list(string)` | `[]` | no |
| vpc_endpoint_configs | List of VPC endpoint configurations | `list(object(...))` | `[]` | no |
| tags | A map of tags to assign to resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| vpc_endpoint_service_name | Service name of the VPC endpoint service |
| vpc_endpoint_service_arn | ARN of the VPC endpoint service |
| vpc_endpoints | Map of VPC endpoint details |
| vpc_endpoint_ids | List of VPC endpoint IDs |
| vpc_endpoint_dns_entries | List of VPC endpoint DNS entries |

## Architecture

### VPC Endpoint Service
- Exposes the GWLB as a service discoverable by other VPCs
- Supports principal-based access control
- Configurable acceptance requirements

### VPC Endpoints
- Consumer endpoints in target VPCs that connect to the GWLB service
- Each endpoint can have individual configuration (subnets, security groups, policies)
- Supports both manual and automatic acceptance
- Network interfaces created in specified subnets for traffic routing

### Cross-VPC Traffic Flow
1. Traffic enters consumer VPC through VPC endpoint
2. VPC endpoint routes traffic to GWLB service
3. GWLB distributes traffic to security appliances
4. Inspected traffic returns through the same path