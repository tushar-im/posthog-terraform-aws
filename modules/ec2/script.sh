#!/bin/bash
set -e

# Update system
apt update
apt upgrade -y

# Install Docker
apt install -y docker.io
systemctl start docker
systemctl enable docker

# Install Docker Compose
curl -L "https://github.com/docker/compose/releases/download/v2.33.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Install Git and configure repository access
apt install -y git

# Setup SSH for Deploy Key
mkdir -p /home/ubuntu/.ssh
echo "${DEPLOY_PRIVATE_KEY}" > /home/ubuntu/.ssh/deploy_key
chmod 600 /home/ubuntu/.ssh/deploy_key
chown ubuntu:ubuntu /home/ubuntu/.ssh/deploy_key

# Configure SSH for GitHub
cat <<EOF > /home/ubuntu/.ssh/config
Host github.com
  IdentityFile /home/ubuntu/.ssh/deploy_key
  StrictHostKeyChecking no
EOF

chown ubuntu:ubuntu /home/ubuntu/.ssh/config
chmod 600 /home/ubuntu/.ssh/config

# Start SSH agent
eval $(ssh-agent -s)
ssh-add /home/ubuntu/.ssh/deploy_key

# POSTHOG INSTALLATION
# Set environment variables
export DEBIAN_FRONTEND=noninteractive
export RESTART_MODE=l
export POSTHOG_APP_TAG="${POSTHOG_APP_TAG}"
export SENTRY_DSN="${SENTRY_DSN}"
export DOMAIN="${DOMAIN}"

# Generate secrets
POSTHOG_SECRET=$(head -c 28 /dev/urandom | sha224sum -b | head -c 56)
export POSTHOG_SECRET
ENCRYPTION_SALT_KEYS=$(openssl rand -hex 16)
export ENCRYPTION_SALT_KEYS

# Clone PostHog repository
git clone git@github.com:PostHog/posthog.git

cd posthog
git pull

# Return to home directory
cd /home/ubuntu

# Create Caddyfile
cat > /home/ubuntu/Caddyfile <<CADDYEOF
{
  # TLS configuration
}
$DOMAIN, http://, https:// {
  encode gzip zstd
  reverse_proxy http://web:8000
  reverse_proxy http://livestream:8666
}
CADDYEOF

# Create .env file
cat > /home/ubuntu/.env <<ENVEOF
POSTHOG_SECRET=$POSTHOG_SECRET
ENCRYPTION_SALT_KEYS=$ENCRYPTION_SALT_KEYS
SENTRY_DSN=$SENTRY_DSN
DOMAIN=$DOMAIN
ENVEOF

# Create compose directory and scripts
mkdir -p /compose

# Create start script
cat > /home/ubuntu/compose/start <<STARTEOF
#!/bin/bash
./compose/wait
./bin/migrate
./bin/docker-server
STARTEOF
chmod +x /home/ubuntu/compose/start

# Create temporal worker script
cat > /home/ubuntu/compose/temporal-django-worker <<WORKEREOF
#!/bin/bash
./bin/temporal-django-worker
WORKEREOF
chmod +x /home/ubuntu/compose/temporal-django-worker

# Create wait script
cat > /home/ubuntu/compose/wait <<WAITEOF
#!/usr/bin/env python3
import socket
import time

def loop():
    print("Waiting for ClickHouse and Postgres to be ready")
    try:
        with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
            s.connect(('clickhouse', 9000))
        print("Clickhouse is ready")
        with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
            s.connect(('db', 5432))
        print("Postgres is ready")
    except ConnectionRefusedError as e:
        time.sleep(5)
        loop()

loop()
WAITEOF
chmod +x /home/ubuntu/compose/wait

# Setup docker-compose files
cp /home/ubuntu/posthog/docker-compose.base.yml /home/ubuntu/docker-compose.base.yml
cp /home/ubuntu/posthog/docker-compose.hobby.yml /home/ubuntu/docker-compose.yml

# Add user to docker group
usermod -aG docker ubuntu

# Start the stack
sudo -u ubuntu docker-compose up -d --no-build --pull always

# Set proper ownership
chown -R ubuntu:ubuntu /home/ubuntu/

echo "PostHog installation complete. It will be available at https://$DOMAIN after DNS propagation."
