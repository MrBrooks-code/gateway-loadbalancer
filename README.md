# AWS Gateway Load Balancer (GWLB) Terraform Module

This Terraform module creates an AWS Gateway Load Balancer with associated target groups, listeners, S3 logging, and optional VPC endpoint services for multi-VPC deployments. Designed for security appliance deployments that need transparent traffic inspection.

## Features

- **Gateway Load Balancer** with GENEVE protocol support
- **Target Group** with configurable health checks and automatic IP target attachments
- **S3 Logging** with secure buckets for access and connection logs
- **VPC Endpoint Service** for cross-VPC connectivity
- **Security Policies** with SSL-only access and encrypted uploads
- **Lifecycle Management** for log retention and cost optimization

## Architecture

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Consumer VPC  │────│  VPC Endpoint    │────│  Security VPC   │
│                 │    │  (PrivateLink)   │    │                 │
└─────────────────┘    └──────────────────┘    │  ┌───────────┐  │
                                               │  │   GWLB    │  │
┌─────────────────┐    ┌──────────────────┐    │  └─────┬─────┘  │
│   Consumer VPC  │────│  VPC Endpoint    │────│        │        │
│                 │    │  (PrivateLink)   │    │  ┌─────▼─────┐  │
└─────────────────┘    └──────────────────┘    │  │ Security  │  │
                                               │  │Appliances │  │
                                               │  └───────────┘  │
                                               └─────────────────┘
```

## Usage

### Basic Example

```hcl
module "gwlb" {
  source = "./path/to/gwlb-module"

  name       = "security-gwlb"
  subnet_ids = ["subnet-123", "subnet-456"]
  vpc_id     = "vpc-abc123"

  # Security appliance targets
  security_appliance_ips = [
    "10.0.1.100",
    "10.0.2.100"
  ]

  # Enable logging
  access_logs_enabled     = true
  connection_logs_enabled = true

  # VPC Endpoint Service for multi-VPC
  create_vpc_endpoint_service = true

  tags = {
    Environment = "production"
    Project     = "security-infrastructure"
  }
}
```

### Complete Example with All Options

```hcl
module "gwlb" {
  source = "./path/to/gwlb-module"

  # Core Configuration
  name       = "security-gwlb"
  subnet_ids = ["subnet-089554e8e508f20f2", "subnet-0a74faadea8030810"]
  vpc_id     = "vpc-0eff1c2f35611e777"

  # Target Configuration
  target_type            = "ip"  # or "instance"
  target_group_port      = 6081  # GENEVE port
  security_appliance_ips = [
    "10.0.1.100",  # Security appliance 1
    "10.0.2.100",  # Security appliance 2
    "10.0.3.100"   # Security appliance 3
  ]

  # Health Check Configuration
  health_check_enabled             = true
  health_check_protocol            = "HTTP"  # or "TCP"
  health_check_port                = "80"    # or "traffic-port"
  health_check_path                = "/health"
  health_check_interval            = 30
  health_check_timeout             = 5
  health_check_healthy_threshold   = 3
  health_check_unhealthy_threshold = 3

  # Load Balancer Settings
  enable_deletion_protection       = false
  enable_cross_zone_load_balancing = true

  # S3 Logging Configuration
  access_logs_enabled     = true
  access_logs_prefix      = "production/access-logs"
  connection_logs_enabled = true
  connection_logs_prefix  = "production/connection-logs"

  # VPC Endpoint Service - Multi-VPC Setup
  create_vpc_endpoint_service      = true
  vpc_endpoint_acceptance_required = true  # Manual approval required
  vpc_endpoint_allowed_principals = [
    "arn:aws:iam::123456789012:root",  # Account 1
    "arn:aws:iam::987654321098:root"   # Account 2
  ]

  # VPC Endpoints - Consumer VPCs (optional)
  vpc_endpoint_configs = [
    {
      name                = "prod-vpc-endpoint"
      vpc_id              = "vpc-prod123"
      subnet_ids          = ["subnet-prod1", "subnet-prod2"]
      security_group_ids  = ["sg-prod-gwlb"]
      private_dns_enabled = false
      auto_accept         = true
      tags = {
        Environment = "production"
        Purpose     = "gwlb-consumer"
      }
    },
    {
      name                = "staging-vpc-endpoint"
      vpc_id              = "vpc-staging456"
      subnet_ids          = ["subnet-staging1", "subnet-staging2"]
      security_group_ids  = ["sg-staging-gwlb"]
      private_dns_enabled = false
      auto_accept         = true
      tags = {
        Environment = "staging"
        Purpose     = "gwlb-consumer"
      }
    }
  ]

  # Resource Tags
  tags = {
    Environment         = "production"
    Project            = "security-infrastructure"
    ManagedBy          = "terraform"
    Owner              = "security-team"
    CostCenter         = "security-ops"
    provisioned_by_user = "CaledoniaCloud"
  }
}
```

## Required Variables

| Variable | Type | Description |
|----------|------|-------------|
| `name` | `string` | Name of the Gateway Load Balancer |
| `subnet_ids` | `list(string)` | List of subnet IDs (one per AZ) |
| `vpc_id` | `string` | VPC ID where resources will be created |

## Important Variables

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `security_appliance_ips` | `list(string)` | `[]` | IP addresses of security appliances |
| `target_type` | `string` | `"ip"` | Target type: "ip" or "instance" |
| `access_logs_enabled` | `bool` | `false` | Enable S3 access logging |
| `connection_logs_enabled` | `bool` | `false` | Enable S3 connection logging |
| `create_vpc_endpoint_service` | `bool` | `false` | Create VPC endpoint service |
| `vpc_endpoint_configs` | `list(object)` | `[]` | VPC endpoint configurations |

## Outputs

| Output | Description |
|--------|-------------|
| `gwlb_arn` | ARN of the Gateway Load Balancer |
| `gwlb_dns_name` | DNS name of the load balancer |
| `target_group_arn` | ARN of the target group |
| `vpc_endpoint_service_name` | Service name for PrivateLink connections |
| `access_logs_bucket_id` | S3 bucket for access logs |
| `connection_logs_bucket_id` | S3 bucket for connection logs |
| `attached_target_ips` | List of attached target IPs |

## Target Attachment

**The module automatically handles target attachments!** Simply specify your security appliance IPs in the `security_appliance_ips` variable:

```hcl
security_appliance_ips = [
  "10.0.1.100",  # Security appliance 1
  "10.0.2.100",  # Security appliance 2
  "10.0.3.100"   # Security appliance 3
]
```

The module will automatically:
- Create target group attachments for each IP
- Use the correct port (6081 - GENEVE)
- Configure health checks
- Output the attached IPs for verification

**No manual `aws_lb_target_group_attachment` resources needed!**

## Multi-VPC Deployment Guide

### Step 1: Deploy GWLB in Security VPC
```hcl
# Deploy with VPC endpoint service enabled
create_vpc_endpoint_service = true
vpc_endpoint_configs = []  # Empty initially
```

### Step 2: Get Service Name
```bash
terraform output vpc_endpoint_service_name
# Example output: com.amazonaws.vpce.us-east-1.vpce-svc-1234567890abcdef0
```

### Step 3: Create Consumer VPC Endpoints
Add consumer VPCs to `vpc_endpoint_configs` or create them separately:

```hcl
resource "aws_vpc_endpoint" "consumer" {
  vpc_id            = "vpc-consumer123"
  service_name      = module.gwlb.vpc_endpoint_service_name
  vpc_endpoint_type = "GatewayLoadBalancer"
  subnet_ids        = ["subnet-consumer1", "subnet-consumer2"]
}
```

### Step 4: Update Route Tables
Route traffic through the VPC endpoint in consumer VPCs:

```hcl
resource "aws_route" "to_gwlb" {
  route_table_id         = aws_route_table.consumer.id
  destination_cidr_block = "0.0.0.0/0"
  vpc_endpoint_id        = aws_vpc_endpoint.consumer.id
}
```

## Health Check Configuration

### TCP Health Checks (Default)
```hcl
health_check_protocol = "TCP"
health_check_port     = "traffic-port"  # Uses target group port (6081)
```

### HTTP Health Checks
```hcl
health_check_protocol = "HTTP"
health_check_port     = "80"           # Dedicated health check port
health_check_path     = "/health"      # Health check endpoint
```

## Security Features

The module automatically configures:

- **S3 Bucket Security**: SSL-only access, encrypted uploads, public access blocking
- **ELB Service Account Permissions**: Automatic log delivery permissions
- **Lifecycle Management**: 90-day retention with intelligent tiering
- **Versioning**: Enabled on all S3 buckets

## Subnet Requirements

- **One subnet per availability zone** (GWLB limitation)
- **Subnets must be in the same VPC** as specified in `vpc_id`
- **Private subnets recommended** for security appliances

## Target Group Considerations

- **Target Type**: Use `"ip"` for IP addresses, `"instance"` for EC2 instances
- **Port 6081**: GENEVE protocol port for traffic forwarding
- **Health Checks**: Configure appropriate health check port and protocol for your appliances

## Troubleshooting

### Common Issues

1. **Subnet AZ Conflict**: Ensure only one subnet per availability zone
2. **Target Health**: Verify security appliances are listening on health check port
3. **VPC Endpoint Service**: Check allowed principals for cross-account access
4. **S3 Permissions**: Module automatically handles ELB service account permissions

### Useful Commands

```bash
# Check target health
aws elbv2 describe-target-health --target-group-arn $(terraform output -raw target_group_arn)

# View VPC endpoint service
aws ec2 describe-vpc-endpoint-services --service-names $(terraform output -raw vpc_endpoint_service_name)

# Check S3 bucket policies
aws s3api get-bucket-policy --bucket $(terraform output -raw access_logs_bucket_id)
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| aws | >= 5.0 |

## Contributing

1. Ensure all variables have descriptions and appropriate defaults
2. Add validation rules for critical variables
3. Update this README when adding new features
4. Test with multiple VPC configurations

## License

This module is provided as-is for educational and operational use.