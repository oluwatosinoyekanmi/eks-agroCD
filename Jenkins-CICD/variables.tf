variable "aws_region" {
  description = "The AWS region to create things in."
  default     = "us-east-1"
}
variable "key_name" {
  description = " SSH keys to connect to ec2 instance"
  default     = "associatekeypair"
}
variable "instance_type" {
  description = "instance type for ec2"
  default     = "t2.medium"
}
variable "ami_id" {
  description = "AMI for Ubuntu Ec2 instance"
  default     = "ami-0f9de6e2d2f067fca"
}
variable "bucket_name" {
  description = "The name of the S3 bucket to create"
  type        = string
  default     = "passociate-buck2"
}

variable "dynamodb_table" {
  description = "The name of the dynamodb table"
  type        = string
  default     = "associate-buck-dynamodb-table"
}

variable "acl" {
  description = "The ACL (Access Control List) for the S3 bucket"
  type        = string
  default     = "private"
}