#!/bin/bash
set -euo pipefail

# ── Install SSM agent ─────────────────────────────────────────────────────────
dnf install -y amazon-ssm-agent
systemctl enable amazon-ssm-agent
systemctl start amazon-ssm-agent

# ── Install k3s ───────────────────────────────────────────────────────────────
curl -sfL https://get.k3s.io | sh -

# Wait for k3s to be ready
until kubectl get nodes 2>/dev/null | grep -q "Ready"; do
  echo "Waiting for k3s..."
  sleep 3
done

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

# ── Configure k3s to use ECR ──────────────────────────────────────────────────
mkdir -p /etc/rancher/k3s
cat > /etc/rancher/k3s/registries.yaml <<EOF
configs:
  "${ecr_registry}":
    auth:
      username: AWS
      password: "$(aws ecr get-login-password --region ${aws_region})"
EOF

# ── Install cert-manager ───────────────────────────────────────────────────────
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/latest/download/cert-manager.yaml

# Wait for cert-manager to be ready
kubectl rollout status deployment/cert-manager -n cert-manager --timeout=120s
kubectl rollout status deployment/cert-manager-webhook -n cert-manager --timeout=120s
