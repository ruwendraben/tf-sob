variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "eu-west-2"
}

variable "instance_name" {
  description = "Name tag for the EC2 instance"
  type        = string
  default     = "tf-prod"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.small"
}

variable "ecr_registry" {
  description = "ECR registry base URL (account.dkr.ecr.region.amazonaws.com)"
  type        = string
}

variable "s3_bucket_name" {
  description = "S3 bucket name for image uploads"
  type        = string
}

variable "ssm_session_secret_path_client" {
  description = "SSM parameter name for client session secret"
  type        = string
}

variable "ssm_session_secret_path_author" {
  description = "SSM parameter name for author session secret"
  type        = string
}

variable "db_name" {
  description = "Database name"
  type        = string
}

variable "db_user" {
  description = "Database user"
  type        = string
}

variable "db_password" {
  description = "Database password — set via secrets.auto.tfvars"
  type        = string
  sensitive   = true
}

variable "max_file_size_mb" {
  description = "Max upload file size in MB"
  type        = number
  default     = 10
}

variable "admin_username" {
  description = "Author admin panel username"
  type        = string
}

variable "admin_password_hash" {
  description = "Author admin password hash (salt:hash) — set via secrets.auto.tfvars"
  type        = string
  sensitive   = true
}

variable "key_pair_name" {
  description = "EC2 key pair name for SSH access. Leave empty to disable SSH key."
  type        = string
  default     = ""
}

variable "root_volume_size" {
  description = "Root EBS volume size in GiB"
  type        = number
  default     = 30
}

variable "allowed_ssh_cidrs" {
  description = "CIDR blocks allowed for SSH (port 22). Restrict to your IP in production."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "allowed_author_cidrs" {
  description = "CIDR blocks allowed to reach the author admin panel (port 3001). Restrict to your IP in production."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}
