module "state_bucket" {
  source      = "./modules/s3"
  bucket_name = var.source_bucket_name
  bucket_tags = {
    Name    = "TerraformState"
    Purpose = "Terraform State Storage"
  }
}

module "replica_bucket" {
  source      = "./modules/s3"
  bucket_name = var.replica_bucket_name
  bucket_tags = {
    Name    = "TerraformStateReplica"
    Purpose = "Terraform State Backup"
  }
}

module "state_lock" {
  source     = "./modules/dynamodb"
  table_name = var.dynamodb_table_name
  table_tags = {
    Name    = "TerraformLockTable"
    Managed = "TERRAFORM"
  }
}

# Configure replication between buckets
resource "aws_iam_role" "replication_role" {
  name = "s3-replication-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "s3.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "replication_policy" {
  name = "replication-policy"
  role = aws_iam_role.replication_role.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:GetReplicationConfiguration",
          "s3:ListBucket"
        ],
        Resource = [module.state_bucket.bucket_arn]
      },
      {
        Effect = "Allow",
        Action = [
          "s3:GetObjectVersion",
          "s3:GetObjectVersionAcl",
          "s3:GetObjectVersionForReplication",
          "s3:ReplicateObject",
          "s3:ReplicateDelete",
          "s3:ReplicateTags"
        ],
        Resource = "${module.state_bucket.bucket_arn}/*"
      },
      {
        Effect = "Allow",
        Action = [
          "s3:PutObject"
        ],
        Resource = "${module.replica_bucket.bucket_arn}/*"
      }
    ]
  })
}

resource "aws_s3_bucket_replication_configuration" "tf_replication" {
  # Depends on both buckets having versioning enabled
  depends_on = [
    module.state_bucket.versioning_configuration,
    module.replica_bucket.versioning_configuration
  ]

  bucket = module.state_bucket.bucket_id
  role   = aws_iam_role.replication_role.arn

  rule {
    id     = "replication-rule"
    status = "Enabled"
    
    destination {
      bucket        = module.replica_bucket.bucket_arn
      storage_class = "STANDARD"
    }
    
    filter {
      prefix = ""
    }
    
    delete_marker_replication {
      status = "Disabled"
    }
  }
}