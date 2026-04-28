resource "aws_instance" "sob" {
  ami                          = var.ami_id
  instance_type                = var.instance_type
  iam_instance_profile         = var.iam_instance_profile
  vpc_security_group_ids       = [var.security_group_id]
  key_name                     = var.key_pair_name != "" ? var.key_pair_name : null
  user_data                    = var.user_data
  user_data_replace_on_change  = true

  root_block_device {
    volume_size           = var.root_volume_size
    volume_type           = "gp3"
    delete_on_termination = true
  }

  tags = {
    Name        = var.instance_name
    Environment = var.environment
  }
}
