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

variable "map_public_ip_on_launch" {
  type        = bool
  description = "map public ip on launch"
  default     = true
}

variable "db_instances_count" {
  type        = number
  description = "number of db instances"
  default     = 2
}

variable "nginx_instances_count" {
  type        = number
  description = "number of nginx instances"
  default     = 2
}

variable "nginx_cidrs" {
  type        = list(string)
  description = "nginx cidr blocks"
  default     = ["10.0.0.0/24", "10.0.1.0/24"]
}

variable "db_cidrs" {
  type        = list(string)
  description = "nginx cidr blocks"
  default     = ["10.0.2.0/24", "10.0.3.0/24"]
}