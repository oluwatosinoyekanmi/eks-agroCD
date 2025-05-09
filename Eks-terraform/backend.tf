terraform {
  backend "s3" {
    bucket = "associate-buck"
    key    = "eks/terraform.tfstate"
    region = "us-east-1"
  }
}
