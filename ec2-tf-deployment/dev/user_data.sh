#!/bin/bash
set -euo pipefail

# ── Install Docker ─────────────────────────────────────────────────────────────
yum update -y
yum install -y docker
systemctl enable docker
systemctl start docker

# ── Login to ECR using instance role (no keys needed) ─────────────────────────
aws ecr get-login-password --region ${aws_region} | \
  docker login --username AWS --password-stdin ${ecr_registry}

# ── Pull latest images ─────────────────────────────────────────────────────────
docker pull ${ecr_registry}/sob/client:latest
docker pull ${ecr_registry}/sob/author:latest

# ── Write env files ────────────────────────────────────────────────────────────
# AWS credentials are NOT included — containers use the EC2 instance role via IMDS.

cat > /opt/client.env <<'ENVEOF'
PORT=3000
MAX_FILE_SIZE_MB=${max_file_size_mb}
AWS_REGION=${aws_region}
S3_BUCKET_NAME=${s3_bucket_name}
SSM_SESSION_SECRET_PATH=${ssm_session_secret_path_client}
DB_HOST=${db_host}
DB_PORT=${db_port}
DB_NAME=${db_name}
DB_USER=${db_user}
DB_PASSWORD=${db_password}
DB_SSL=${db_ssl}
ENVEOF

cat > /opt/author.env <<'ENVEOF'
PORT=3001
MAX_FILE_SIZE_MB=${max_file_size_mb}
AWS_REGION=${aws_region}
S3_BUCKET_NAME=${s3_bucket_name}
SSM_SESSION_SECRET_PATH=${ssm_session_secret_path_author}
ADMIN_USERNAME=${admin_username}
ADMIN_PASSWORD_HASH=${admin_password_hash}
DB_HOST=${db_host}
DB_PORT=${db_port}
DB_NAME=${db_name}
DB_USER=${db_user}
DB_PASSWORD=${db_password}
DB_SSL=${db_ssl}
ENVEOF

chmod 600 /opt/client.env /opt/author.env

# ── Start containers ───────────────────────────────────────────────────────────
docker run -d \
  --name sob-client \
  --restart unless-stopped \
  --env-file /opt/client.env \
  -p 80:3000 \
  ${ecr_registry}/sob/client:latest

docker run -d \
  --name sob-author \
  --restart unless-stopped \
  --env-file /opt/author.env \
  -p 3001:3001 \
  ${ecr_registry}/sob/author:latest
