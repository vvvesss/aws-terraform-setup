#(initially commented)
terraform {
  backend "s3" {
    bucket         = "ves-tf-state-bucket"  # Replace with your bucket name
    key            = "terraform/state/terraform.tfstate"
    region         = "eu-central-1"       # Replace with your region
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}

