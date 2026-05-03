# Non-secret values — safe to commit
aws_region     = "eu-west-2"
instance_name  = "tf-prod"
ecr_registry   = "397059225137.dkr.ecr.eu-west-2.amazonaws.com"
s3_bucket_name = "prod-images-shopsonboard"

ssm_session_secret_path_client = "sob-sec-session-prod"
ssm_session_secret_path_author = "sob-sec-session-prod"

db_name = "sob_db"
db_user = "sob_user"

max_file_size_mb = 10
admin_username   = "admin"

key_pair_name    = "tf_ec2_instance"
root_volume_size = 30
