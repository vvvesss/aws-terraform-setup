output "state_bucket_name" {
  description = "Name of the S3 bucket for Terraform state"
  value       = module.state_bucket.bucket_name
}

output "replica_bucket_name" {
  description = "Name of the replica S3 bucket for Terraform state"
  value       = module.replica_bucket.bucket_name
}

output "dynamodb_table_name" {
  description = "Name of the DynamoDB table for state locking"
  value       = module.state_lock.table_name
}
