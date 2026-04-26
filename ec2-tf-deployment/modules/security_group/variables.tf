variable "instance_name" {
  description = "Name tag base for security group"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where security group is created"
  type        = string
}

variable "allowed_ssh_cidrs" {
  description = "CIDR blocks allowed for SSH"
  type        = list(string)
}

variable "allowed_author_cidrs" {
  description = "CIDR blocks allowed for author app"
  type        = list(string)
}

variable "environment" {
  description = "Environment tag"
  type        = string
}
