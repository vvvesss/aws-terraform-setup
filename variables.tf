variable "aws_region" {
  description = "AWS region where resources will be created"
  type        = string
  default     = "eu-central-1"
}

variable "source_bucket_name" {
  description = "Name of the S3 bucket for Terraform state"
  type        = string
}

variable "replica_bucket_name" {
  description = "Name of the replica S3 bucket for Terraform state"
  type        = string
}

variable "dynamodb_table_name" {
  description = "Name of the DynamoDB table for state locking"
  type        = string
  default     = "terraform-locks"
}
