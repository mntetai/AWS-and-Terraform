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

variable "private_subnet_count" {
  type        = number
  description = "number of private subnets"
  default     = 2
}

variable "public_subnet_count" {
  type        = number
  description = "number of public subnets"
  default     = 2
}

variable "public_cidrs" {
  type        = list(string)
  description = "public subnets cidr blocks"
  default     = ["10.0.0.0/24", "10.0.1.0/24"]
}

variable "private_cidrs" {
  type        = list(string)
  description = "private subnet cidr blocks"
  default     = ["10.0.2.0/24", "10.0.3.0/24"]
}

variable "nginx_instances_count" {
  type        = number
  description = "number of nginx instances"
  default     = 5
}

variable "db_instances_count" {
  type        = number
  description = "number of db instances"
  default     = 5
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