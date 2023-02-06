terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }
  backend "s3" {
    bucket = "terraform-state-etai"
    key    = "aws-and-terraform-state"
    region = "us-east-1"
  }
  required_version = ">= 1.2.0"
}

provider "aws" {
  region                   = var.AWS_region
  shared_config_files      = ["~/.aws/config"]
  shared_credentials_files = ["~/.aws/credentials"]
  profile                  = "ec2admin"
}