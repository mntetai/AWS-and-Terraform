variable "AWS_region" {
  type        = string
  description = "Aws region"
  default     = "us-east-1"
}

variable "enable_dns_hostnames" {
  type        = bool
  description = "enable dns host names"
  default     = true
}

variable "nginx_instances_count" {
  type        = number
  description = "number of nginx instances"
  default     = 2
}

variable "db_instances_count" {
  type        = number
  description = "number of db instances"
  default     = 2
}

# cidr range addreses #
variable "vpc_cidr_range" {
  type        = string
  description = "vpc cider range"
  default     = "10.0.0.0/16"
}

variable "internet_cidr_range" {
  type        = string
  description = "internet cidr range"
  default     = "0.0.0.0/0"
}

variable "key_name" {
  description = "AWS key pair name"
  default     = "opsschool"
}