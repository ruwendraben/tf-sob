resource "aws_instance" "sob" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  iam_instance_profile   = var.iam_instance_profile
  vpc_security_group_ids = [var.security_group_id]
  key_name               = var.key_pair_name != "" ? var.key_pair_name : null
  user_data              = var.user_data

  tags = {
    Name        = var.instance_name
    Environment = var.environment
  }
}
