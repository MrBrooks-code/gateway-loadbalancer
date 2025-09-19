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

variable "gateway_load_balancer_arns" {
  description = "List of Gateway Load Balancer ARNs to attach to the VPC endpoint service"
  type        = list(string)
}

variable "vpc_endpoint_allowed_principals" {
  description = "List of principals allowed to discover the VPC endpoint service"
  type        = list(string)
  default     = []
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

variable "tags" {
  description = "A map of tags to assign to the resources"
  type        = map(string)
  default     = {}
}


variable "profile" {
  type        = string
  description = "Profile used to access AWS."
  default = "cc"
}

variable "region" {
  type        = string
  description = "AWS Region"
  default = "us-east-1"
}