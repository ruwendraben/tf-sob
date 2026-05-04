terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.5.0"
}

provider "aws" {
  region = var.aws_region
}

# ── Data sources ───────────────────────────────────────────────────────────────

data "aws_vpc" "default" {
  default = true
}

data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

module "iam" {
  source = "../modules/iam"

  instance_name  = var.instance_name
  s3_bucket_name = var.s3_bucket_name
  environment    = "dev"
}

module "security_group" {
  source = "../modules/security_group"

  instance_name        = var.instance_name
  vpc_id               = data.aws_vpc.default.id
  allowed_ssh_cidrs    = var.allowed_ssh_cidrs
  allowed_author_cidrs = var.allowed_author_cidrs
  environment          = "dev"
}

module "ec2" {
  source = "../modules/ec2"

  instance_name        = var.instance_name
  ami_id               = data.aws_ami.amazon_linux_2023.id
  iam_instance_profile = module.iam.instance_profile_name
  security_group_id    = module.security_group.security_group_id
  key_pair_name        = var.key_pair_name
  root_volume_size     = var.root_volume_size
  environment          = "dev"

  user_data = templatefile("${path.module}/user_data.sh", {
    aws_region                     = var.aws_region
    ecr_registry                   = var.ecr_registry
    s3_bucket_name                 = var.s3_bucket_name
    ssm_session_secret_path_client = var.ssm_session_secret_path_client
    ssm_session_secret_path_author = var.ssm_session_secret_path_author
    db_host                        = var.db_host
    db_port                        = var.db_port
    db_name                        = var.db_name
    db_user                        = var.db_user
    db_password                    = var.db_password
    db_ssl                         = var.db_ssl
    max_file_size_mb               = var.max_file_size_mb
    admin_username                 = var.admin_username
    admin_password_hash            = var.admin_password_hash
  })
}

resource "aws_eip" "sob" {
  domain = "vpc"

  tags = {
    Name        = "${var.instance_name}-eip"
    Environment = "dev"
  }
}

resource "aws_eip_association" "sob" {
  instance_id   = module.ec2.instance_id
  allocation_id = aws_eip.sob.id
}
