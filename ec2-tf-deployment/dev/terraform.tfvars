# Non-secret values — safe to commit
aws_region     = "eu-west-2"
instance_name  = "tf-dev"
ecr_registry   = "397059225137.dkr.ecr.eu-west-2.amazonaws.com"
s3_bucket_name = "test-images-shopsonboard"

ssm_session_secret_path_client = "sob-sec-session"
ssm_session_secret_path_author = "sob-sec-session"

db_host = "database-1.c10umwmwydqv.eu-west-2.rds.amazonaws.com"
db_port = 5432
db_name = "sob_db"
db_user = "sob_user"
db_ssl  = true

max_file_size_mb = 10
admin_username   = "admin"

key_pair_name = "tf_ec2_instance"
root_volume_size = 30
