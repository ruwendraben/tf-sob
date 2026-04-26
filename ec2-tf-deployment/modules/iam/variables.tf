variable "instance_name" {
  description = "Name tag base for IAM resources"
  type        = string
}

variable "s3_bucket_name" {
  description = "S3 bucket name for scoped policy"
  type        = string
}

variable "environment" {
  description = "Environment tag"
  type        = string
}
