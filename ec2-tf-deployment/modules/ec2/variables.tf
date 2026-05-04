variable "instance_name" {
  description = "Name tag for EC2 instance"
  type        = string
}

variable "ami_id" {
  description = "AMI ID for EC2 instance"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "root_volume_size" {
  description = "Root EBS volume size in GiB"
  type        = number
  default     = 30
}

variable "iam_instance_profile" {
  description = "IAM instance profile name"
  type        = string
}

variable "security_group_id" {
  description = "Security group ID"
  type        = string
}

variable "key_pair_name" {
  description = "EC2 key pair name; empty disables SSH key assignment"
  type        = string
  default     = ""
}

variable "user_data" {
  description = "Rendered user_data script"
  type        = string
}

variable "environment" {
  description = "Environment tag"
  type        = string
}

variable "availability_zone" {
  description = "AZ to launch the instance in; empty means AWS chooses"
  type        = string
  default     = ""
}
