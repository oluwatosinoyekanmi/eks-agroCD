# terraform {
#   required_providers {
#     aws = {
#       source  = "hashicorp/aws"
#       version = "~> 5.0"
#     }
#   }
# }

# # # Configure the AWS Provider
# # provider "aws" {
# #   region = "ap-south-1"
# # }

# provider "aws" {
#   region  = "us-east-1"
#   profile = "AdministratorAccess-442426875219"
# }


////jenkins
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# AWS Provider using environment variables
provider "aws" {
  region  = var.AWS_REGION
  profile = var.AWS_PROFILE
}

variable "AWS_REGION" {
  description = "The AWS region to operate in"
  type        = string
}

variable "AWS_PROFILE" {
  description = "The AWS CLI profile to use"
  type        = string
  default     = "AdministratorAccess-442426875219"  # Or leave it empty if no default is set
}
