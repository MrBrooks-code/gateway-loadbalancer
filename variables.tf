variable "name" {
  description = "Name of the Gateway Load Balancer"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs to attach to the Gateway Load Balancer"
  type        = list(string)
}

variable "vpc_id" {
  description = "VPC ID where the target group will be created"
  type        = string
}

variable "enable_deletion_protection" {
  description = "Enable deletion protection for the Gateway Load Balancer"
  type        = bool
  default     = false
}

variable "target_group_port" {
  description = "Port on which targets receive traffic from the load balancer"
  type        = number
  default     = 6081
}

variable "target_type" {
  description = "Type of target that you must specify when registering targets with this target group"
  type        = string
  default     = "ip"
  validation {
    condition     = contains(["instance", "ip"], var.target_type)
    error_message = "Target type must be either 'instance' or 'ip'."
  }
}

variable "health_check_enabled" {
  description = "Whether health checks are enabled"
  type        = bool
  default     = true
}

variable "health_check_healthy_threshold" {
  description = "Number of consecutive health checks successes required before considering an unhealthy target healthy"
  type        = number
  default     = 3
}

variable "health_check_interval" {
  description = "Approximate amount of time, in seconds, between health checks of an individual target"
  type        = number
  default     = 30
}

variable "health_check_matcher" {
  description = "Response codes to use when checking for a healthy responses from a target"
  type        = string
  default     = null
}

variable "health_check_path" {
  description = "Destination for the health check request. Only used with HTTP/HTTPS protocols (ignored for TCP)"
  type        = string
  default     = "/health"
}

variable "health_check_port" {
  description = "Port to use to connect with the target for health checking. Use 'traffic-port' for GENEVE port (6081) or specify a dedicated health check port (e.g., '8080', '80')"
  type        = string
  default     = "80"
}

variable "health_check_protocol" {
  description = "Protocol to use to connect with the target for health checking. For GWLB: TCP for port-based checks, HTTP/HTTPS for path-based checks"
  type        = string
  default     = "HTTP"
  validation {
    condition     = contains(["TCP", "HTTP", "HTTPS"], var.health_check_protocol)
    error_message = "Health check protocol must be one of: TCP, HTTP, HTTPS."
  }
}

variable "health_check_timeout" {
  description = "Amount of time, in seconds, during which no response means a failed health check"
  type        = number
  default     = 5
}

variable "health_check_unhealthy_threshold" {
  description = "Number of consecutive health check failures required before considering the target unhealthy"
  type        = number
  default     = 3
}

variable "stickiness_enabled" {
  description = "Whether to enable sticky sessions"
  type        = bool
  default     = false
}

variable "access_logs_enabled" {
  description = "Whether to enable access logs"
  type        = bool
  default     = false
}


variable "access_logs_prefix" {
  description = "S3 bucket prefix for access logs"
  type        = string
  default     = "access-logs"
}

variable "create_vpc_endpoint_service" {
  description = "Whether to create a VPC endpoint service for the Gateway Load Balancer"
  type        = bool
  default     = false
}

variable "vpc_endpoint_acceptance_required" {
  description = "Whether acceptance is required for the VPC endpoint service"
  type        = bool
  default     = false
}

variable "vpc_endpoint_allowed_principals" {
  description = "List of principals allowed to discover the VPC endpoint service"
  type        = list(string)
  default     = []
}

variable "enable_cross_zone_load_balancing" {
  description = "Enable cross-zone load balancing for the Gateway Load Balancer"
  type        = bool
  default     = false
}

variable "desync_mitigation_mode" {
  description = "How the load balancer handles requests that might pose a security risk to an application"
  type        = string
  default     = "defensive"
  validation {
    condition     = contains(["monitor", "defensive", "strictest"], var.desync_mitigation_mode)
    error_message = "Desync mitigation mode must be one of: monitor, defensive, strictest."
  }
}

variable "enable_xff_client_port" {
  description = "Whether the X-Forwarded-For header should preserve the source port that the client used to connect to the load balancer"
  type        = bool
  default     = false
}

variable "xff_header_processing_mode" {
  description = "Determines how the load balancer modifies the X-Forwarded-For header in the HTTP request"
  type        = string
  default     = "append"
  validation {
    condition     = contains(["append", "preserve", "remove"], var.xff_header_processing_mode)
    error_message = "XFF header processing mode must be one of: append, preserve, remove."
  }
}

variable "preserve_host_header" {
  description = "Whether the Application Load Balancer should preserve the Host header in the HTTP request and send it to the target without any change"
  type        = bool
  default     = false
}

variable "idle_timeout" {
  description = "The time in seconds that the connection is allowed to be idle"
  type        = number
  default     = 60
  validation {
    condition     = var.idle_timeout >= 1 && var.idle_timeout <= 4000
    error_message = "Idle timeout must be between 1 and 4000 seconds."
  }
}

variable "client_keep_alive" {
  description = "Client keep alive value in seconds"
  type        = number
  default     = 3600
  validation {
    condition     = var.client_keep_alive >= 60 && var.client_keep_alive <= 604800
    error_message = "Client keep alive must be between 60 and 604800 seconds."
  }
}

variable "enable_http2" {
  description = "Whether HTTP/2 is enabled"
  type        = bool
  default     = true
}

variable "enable_tls_version_and_cipher_suite_headers" {
  description = "Whether the two headers (x-amzn-tls-version and x-amzn-tls-cipher-suite) are added to the client request"
  type        = bool
  default     = false
}

variable "enable_waf_fail_open" {
  description = "Whether to allow a WAF-enabled load balancer to route requests to targets if it is unable to forward the request to AWS WAF"
  type        = bool
  default     = false
}

variable "drop_invalid_header_fields" {
  description = "Whether HTTP headers with header names that are not valid are removed by the load balancer (true) or routed to targets (false)"
  type        = bool
  default     = false
}

variable "connection_logs_enabled" {
  description = "Whether to enable connection logs"
  type        = bool
  default     = false
}


variable "connection_logs_prefix" {
  description = "S3 bucket prefix for connection logs"
  type        = string
  default     = "connection-logs"
}

variable "subnet_mappings" {
  description = "A list of subnet mapping blocks describing subnets to attach to load balancer"
  type = list(object({
    subnet_id            = string
    allocation_id        = optional(string)
    ipv6_address         = optional(string)
    private_ipv4_address = optional(string)
  }))
  default = []
}

variable "lb_create_timeout" {
  description = "Timeout value when creating the load balancer"
  type        = string
  default     = "10m"
}

variable "lb_update_timeout" {
  description = "Timeout value when updating the load balancer"
  type        = string
  default     = "10m"
}

variable "lb_delete_timeout" {
  description = "Timeout value when deleting the load balancer"
  type        = string
  default     = "10m"
}

variable "vpc_endpoint_configs" {
  description = "List of VPC endpoint configurations for consumers in other VPCs"
  type = list(object({
    name                = string
    vpc_id              = string
    subnet_ids          = list(string)
    security_group_ids  = optional(list(string))
    private_dns_enabled = optional(bool, false)
    auto_accept         = optional(bool, true)
    policy              = optional(string)
    tags                = optional(map(string), {})
  }))
  default = []
}

variable "vpc_endpoint_create_timeout" {
  description = "Timeout value when creating VPC endpoints"
  type        = string
  default     = "10m"
}

variable "vpc_endpoint_update_timeout" {
  description = "Timeout value when updating VPC endpoints"
  type        = string
  default     = "10m"
}

variable "vpc_endpoint_delete_timeout" {
  description = "Timeout value when deleting VPC endpoints"
  type        = string
  default     = "10m"
}


variable "security_appliance_ips" {
  description = "List of security appliance IP addresses to attach as targets"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "A map of tags to assign to the resources"
  type        = map(string)
  default     = {}
}

variable "profile" {
    description = "The AWS profile to use"
    type        = string
    default     = "cc"
}

variable "region" {
    description = "The AWS region to use"
    type        = string
    default     = "us-east-1"
}