provider "aws" {
  region = "ap-south-1"
}

# Data block
data "aws_security_group" "for_testing_sg" {
  filter {
    name   = "group-name"
    values = ["for-testing-sg"]
  }
}

# -----------------------------
# EC2 Instance
# -----------------------------
resource "aws_instance" "instance_1" {
  ami           = "ami-07216ac99dc46a187"
  instance_type = "t2.micro"

  key_name = "deployment-server"

  vpc_security_group_ids = [
    data.aws_security_group.for_testing_sg.id
  ]

  tags = {
    Name = "TF-Instance"
    Env  = "dev"
  }
}

# -----------------------------
# S3 Bucket
# -----------------------------
resource "aws_s3_bucket" "tf_bucket" {
  bucket = "tf-demo-bucket-12345-22-04-26"

  tags = {
    Name = "TF-S3-Bucket"
    Env  = "dev"
  }
}

# Enable versioning
resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.tf_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Block public access (Best Practice)
resource "aws_s3_bucket_public_access_block" "block_public" {
  bucket = aws_s3_bucket.tf_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# -----------------------------
# AWS Secrets Manager
# -----------------------------

# Secret metadata
resource "aws_secretsmanager_secret" "my_secret" {
  name = "dev/new/secret"

  tags = {
    Env = "dev"
  }
}

# Secret value
resource "aws_secretsmanager_secret_version" "secret_value" {
  secret_id = aws_secretsmanager_secret.my_secret.id

  secret_string = jsonencode({
    username = "admin"
    password = "123"
  })
}
