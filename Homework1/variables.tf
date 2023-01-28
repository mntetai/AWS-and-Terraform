variable "AWS_region" {
  type        = string
  description = "Aws region"
  default     = "us-east-1"
}

variable "enable_dns_hostnames" {
  type = bool
  description = "enable dns host names"
  default = true
}

variable "map_public_ip_on_launch" {
  type = bool
  description = "map public ip on launch"
  default = true
}
