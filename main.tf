resource "aws_lb" "gwlb" {
  name               = var.name
  load_balancer_type = "gateway"
  subnets            = var.subnet_ids

  enable_deletion_protection                  = var.enable_deletion_protection
  enable_cross_zone_load_balancing            = var.enable_cross_zone_load_balancing
  desync_mitigation_mode                      = var.desync_mitigation_mode
  enable_xff_client_port                      = var.enable_xff_client_port
  xff_header_processing_mode                  = var.xff_header_processing_mode
  preserve_host_header                        = var.preserve_host_header
  idle_timeout                                = var.idle_timeout
  client_keep_alive                           = var.client_keep_alive
  enable_http2                                = var.enable_http2
  enable_tls_version_and_cipher_suite_headers = var.enable_tls_version_and_cipher_suite_headers
  enable_waf_fail_open                        = var.enable_waf_fail_open
  drop_invalid_header_fields                  = var.drop_invalid_header_fields

  dynamic "access_logs" {
    for_each = var.access_logs_enabled ? [1] : []
    content {
      bucket  = module.s3_access_logs.bucket_id
      prefix  = var.access_logs_prefix
      enabled = var.access_logs_enabled
    }
  }

  dynamic "connection_logs" {
    for_each = var.connection_logs_enabled ? [1] : []
    content {
      bucket  = module.s3_connection_logs.bucket_id
      prefix  = var.connection_logs_prefix
      enabled = var.connection_logs_enabled
    }
  }

  dynamic "subnet_mapping" {
    for_each = var.subnet_mappings
    content {
      subnet_id            = subnet_mapping.value.subnet_id
      allocation_id        = lookup(subnet_mapping.value, "allocation_id", null)
      ipv6_address         = lookup(subnet_mapping.value, "ipv6_address", null)
      private_ipv4_address = lookup(subnet_mapping.value, "private_ipv4_address", null)
    }
  }

  timeouts {
    create = var.lb_create_timeout
    update = var.lb_update_timeout
    delete = var.lb_delete_timeout
  }

  tags = var.tags
}

resource "aws_lb_target_group" "gwlb" {
  name        = "${var.name}-tg"
  port        = var.target_group_port
  protocol    = "GENEVE"
  target_type = var.target_type
  vpc_id      = var.vpc_id

  health_check {
    enabled             = var.health_check_enabled
    healthy_threshold   = var.health_check_healthy_threshold
    interval            = var.health_check_interval
    matcher             = var.health_check_matcher
    path                = var.health_check_path
    port                = var.health_check_port
    protocol            = var.health_check_protocol
    timeout             = var.health_check_timeout
    unhealthy_threshold = var.health_check_unhealthy_threshold
  }

  stickiness {
    enabled = var.stickiness_enabled
    type    = "source_ip_dest_ip_proto"
  }

  tags = var.tags
}

resource "aws_lb_listener" "gwlb" {
  load_balancer_arn = aws_lb.gwlb.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.gwlb.arn
  }

  tags = var.tags
}

# Target group attachments for security appliances
resource "aws_lb_target_group_attachment" "security_appliances" {
  count = length(var.security_appliance_ips)

  target_group_arn = aws_lb_target_group.gwlb.arn
  target_id        = var.security_appliance_ips[count.index]
  port             = var.target_group_port
}

module "s3_access_logs" {
  source = "./s3"

  enabled     = var.access_logs_enabled
  bucket_name = "${var.name}-access-logs"

  # Security configurations for GWLB access logs
  acl                     = null # Use bucket policies instead
  s3_object_ownership     = "BucketOwnerEnforced"
  versioning_enabled      = true
  sse_algorithm           = "AES256"
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  # S3 security policies - use built-in module features
  allow_ssl_requests_only = true
  allow_encrypted_uploads_only = true

  # Grant ELB service account access for log delivery
  privileged_principal_arns = var.access_logs_enabled ? [
    {
      (data.aws_elb_service_account.current[0].arn) = [""]
    }
  ] : []
  privileged_principal_actions = [
    "s3:PutObject",
    "s3:GetBucketAcl"
  ]

  # Lifecycle management - automatically transition and expire logs
  lifecycle_configuration_rules = [
    {
      id      = "gwlb-access-logs-lifecycle"
      enabled = true
      expiration = {
        days = 90
      }
      noncurrent_version_expiration = {
        days = 30
      }
      transition = [
        {
          days          = 30
          storage_class = "STANDARD_IA"
        },
        {
          days          = 60
          storage_class = "GLACIER"
        }
      ]
    }
  ]

  tags = merge(var.tags, {
    Purpose = "gwlb-access-logs"
    Name    = "${var.name}-access-logs"
  })
}

module "s3_connection_logs" {
  source = "./s3"

  enabled     = var.connection_logs_enabled
  bucket_name = "${var.name}-connection-logs"

  # Security configurations for GWLB connection logs
  acl                     = null # Use bucket policies instead
  s3_object_ownership     = "BucketOwnerEnforced"
  versioning_enabled      = true
  sse_algorithm           = "AES256"
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  # S3 security policies - use built-in module features
  allow_ssl_requests_only = true
  allow_encrypted_uploads_only = true

  # Grant ELB service account access for log delivery
  privileged_principal_arns = var.connection_logs_enabled ? [
    {
      (data.aws_elb_service_account.current[0].arn) = [""]
    }
  ] : []
  privileged_principal_actions = [
    "s3:PutObject",
    "s3:GetBucketAcl"
  ]

  # Lifecycle management - automatically transition and expire logs
  lifecycle_configuration_rules = [
    {
      id      = "gwlb-connection-logs-lifecycle"
      enabled = true
      expiration = {
        days = 90
      }
      noncurrent_version_expiration = {
        days = 30
      }
      transition = [
        {
          days          = 30
          storage_class = "STANDARD_IA"
        },
        {
          days          = 60
          storage_class = "GLACIER"
        }
      ]
    }
  ]

  tags = merge(var.tags, {
    Purpose = "gwlb-connection-logs"
    Name    = "${var.name}-connection-logs"
  })
}

data "aws_elb_service_account" "current" {
  count = var.access_logs_enabled || var.connection_logs_enabled ? 1 : 0
}

module "endpoint" {
  source = "./endpoint"

  create_vpc_endpoint_service      = var.create_vpc_endpoint_service
  vpc_endpoint_acceptance_required = var.vpc_endpoint_acceptance_required
  gateway_load_balancer_arns       = [aws_lb.gwlb.arn]
  vpc_endpoint_allowed_principals  = var.vpc_endpoint_allowed_principals
  vpc_endpoint_configs             = var.vpc_endpoint_configs
  vpc_endpoint_create_timeout      = var.vpc_endpoint_create_timeout
  vpc_endpoint_update_timeout      = var.vpc_endpoint_update_timeout
  vpc_endpoint_delete_timeout      = var.vpc_endpoint_delete_timeout

  tags = var.tags
}