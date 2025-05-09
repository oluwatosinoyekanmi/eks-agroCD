terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  required_version = ">= 1.3.0"
}

provider "aws" {
  region = "us-east-1"  # Change to your target region if needed
}

# provider "aws" {
#   region  = "us-east-1"
#   profile = "AdministratorAccess-442426875219"
# }
