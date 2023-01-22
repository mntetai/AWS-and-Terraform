variable "instance_count" {
  type        = number
  description = "Number of instances"
  default     = 2
}

variable "AWS_region" {
  type        =  string
  description = "Aws region"
  default     = "us-east-1"
}
