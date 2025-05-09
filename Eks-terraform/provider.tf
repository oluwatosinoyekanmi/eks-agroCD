terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region     = "us-east-1"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}


# provider "aws" {
#   region  = "us-east-1"
#   profile = "AdministratorAccess-442426875219"
# }
