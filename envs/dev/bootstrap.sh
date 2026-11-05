#!/bin/bash
apt-get update -y && apt-get install -y nginx awscli curl
# Agent SSM : absent de l'AMI Debian officielle, requis pour Session Manager (verification de app.conf).
# Paquet officiel, region us-east-1 : https://docs.aws.amazon.com/systems-manager/latest/userguide/agent-install-deb.html
curl -fsSL -o /tmp/amazon-ssm-agent.deb https://s3.us-east-1.amazonaws.com/amazon-ssm-us-east-1/latest/debian_amd64/amazon-ssm-agent.deb
dpkg -i /tmp/amazon-ssm-agent.deb
systemctl enable --now amazon-ssm-agent
mkdir -p /etc/novasphere
aws ssm get-parameter --region us-east-1 --name /novasphere/dev/db_password \
  --with-decryption --query Parameter.Value --output text > /etc/novasphere/app.conf
chmod 0640 /etc/novasphere/app.conf
echo "<h1>NovaSphere</h1><p>$(hostname)</p>" > /var/www/html/index.html
systemctl enable --now nginx
