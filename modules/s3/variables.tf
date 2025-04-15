variable "bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
}

variable "force_destroy" {
  description = "Allow deletion of non-empty bucket"
  type        = bool
  default     = true
}

variable "bucket_tags" {
  description = "Tags to apply to the bucket"
  type        = map(string)
  default     = {}
}
