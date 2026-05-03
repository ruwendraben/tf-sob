#!/bin/bash
set -euo pipefail

# ── Install Docker ─────────────────────────────────────────────────────────────
yum update -y
yum install -y docker
systemctl enable docker
systemctl start docker

# ── Mount persistent EBS volume for Postgres ──────────────────────────────────
# /dev/xvdf is the EBS volume attached via Terraform
EBS_DEVICE=/dev/xvdf
PG_MOUNT=/mnt/postgres-data

# Format only if the volume has no filesystem yet (safe on subsequent boots)
if ! blkid "$EBS_DEVICE" > /dev/null 2>&1; then
  mkfs.ext4 "$EBS_DEVICE"
fi

mkdir -p "$PG_MOUNT"
mount "$EBS_DEVICE" "$PG_MOUNT"

# Persist the mount across reboots
echo "$EBS_DEVICE $PG_MOUNT ext4 defaults,nofail 0 2" >> /etc/fstab

# Postgres needs to own the data directory
mkdir -p "$PG_MOUNT/data"
chown -R 999:999 "$PG_MOUNT/data"   # UID 999 = postgres user inside the container

# ── Create shared Docker network ──────────────────────────────────────────────
docker network create sob-net

# ── Start Postgres container ───────────────────────────────────────────────────
docker run -d \
  --name postgres \
  --restart unless-stopped \
  --network sob-net \
  -e POSTGRES_DB=${db_name} \
  -e POSTGRES_USER=${db_user} \
  -e POSTGRES_PASSWORD=${db_password} \
  -v /mnt/postgres-data/data:/var/lib/postgresql/data \
  postgres:16-alpine

# Wait for Postgres to be ready
until docker exec postgres pg_isready -U ${db_user} -d ${db_name}; do
  echo "Waiting for Postgres..."
  sleep 2
done

# ── Login to ECR using instance role (no keys needed) ─────────────────────────
aws ecr get-login-password --region ${aws_region} | \
  docker login --username AWS --password-stdin ${ecr_registry}

# ── Pull latest images ─────────────────────────────────────────────────────────
docker pull ${ecr_registry}/sob-prod/client:latest
docker pull ${ecr_registry}/sob-prod/author:latest

# ── Write env files ────────────────────────────────────────────────────────────
# AWS credentials are NOT included — containers use the EC2 instance role via IMDS.

cat > /opt/client.env <<'ENVEOF'
PORT=3000
MAX_FILE_SIZE_MB=${max_file_size_mb}
AWS_REGION=${aws_region}
S3_BUCKET_NAME=${s3_bucket_name}
SSM_SESSION_SECRET_PATH=${ssm_session_secret_path_client}
DB_HOST=postgres
DB_PORT=5432
DB_NAME=${db_name}
DB_USER=${db_user}
DB_PASSWORD=${db_password}
DB_SSL=false
ENVEOF

cat > /opt/author.env <<'ENVEOF'
PORT=3001
MAX_FILE_SIZE_MB=${max_file_size_mb}
AWS_REGION=${aws_region}
S3_BUCKET_NAME=${s3_bucket_name}
SSM_SESSION_SECRET_PATH=${ssm_session_secret_path_author}
ADMIN_USERNAME=${admin_username}
ADMIN_PASSWORD_HASH=${admin_password_hash}
DB_HOST=postgres
DB_PORT=5432
DB_NAME=${db_name}
DB_USER=${db_user}
DB_PASSWORD=${db_password}
DB_SSL=false
ENVEOF

chmod 600 /opt/client.env /opt/author.env

# ── Start containers ───────────────────────────────────────────────────────────
docker run -d \
  --name sob-client \
  --restart unless-stopped \
  --network sob-net \
  --env-file /opt/client.env \
  -p 80:3000 \
  ${ecr_registry}/sob-prod/client:latest

docker run -d \
  --name sob-author \
  --restart unless-stopped \
  --network sob-net \
  --env-file /opt/author.env \
  -p 3001:3001 \
  ${ecr_registry}/sob-prod/author:latest
