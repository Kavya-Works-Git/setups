#!/bin/bash
# ============================================
# SonarQube Installation Script (Ubuntu EC2)
# Run as root. Tested and fixed - Aug 2026
# Launch instance with port 9000 open, t2.medium or larger
# ============================================

set -e

echo ">>> Updating packages..."
apt update -y

echo ">>> Installing Java 17 and dependencies..."
apt install -y openjdk-17-jdk unzip wget

echo ">>> Applying required kernel setting (SonarQube needs this to start)..."
sysctl -w vm.max_map_count=262144
# Make it persist across reboots
grep -q "vm.max_map_count" /etc/sysctl.conf || echo "vm.max_map_count=262144" >> /etc/sysctl.conf

echo ">>> Creating sonar user WITH home directory..."
useradd -m sonar || echo "User already exists, fixing home dir..."
usermod -d /home/sonar -m sonar 2>/dev/null || true

echo ">>> Downloading SonarQube..."
cd /opt
SONAR_VERSION="8.9.6.50800"   # check latest LTS at https://www.sonarsource.com/products/sonarqube/downloads/
wget -q https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-${SONAR_VERSION}.zip -O sonarqube.zip

echo ">>> Extracting..."
unzip -q -o sonarqube.zip
rm sonarqube.zip

echo ">>> Removing any stale temp folder (prevents permission crash on first start)..."
rm -rf /opt/sonarqube-${SONAR_VERSION}/temp

echo ">>> Setting ownership..."
chown -R sonar:sonar /opt/sonarqube-${SONAR_VERSION}

echo ">>> Creating systemd service (so it survives reboots, no manual console needed)..."
cat > /etc/systemd/system/sonarqube.service << EOF
[Unit]
Description=SonarQube Service
After=network.target

[Service]
Type=forking
ExecStart=/opt/sonarqube-${SONAR_VERSION}/bin/linux-x86-64/sonar.sh start
ExecStop=/opt/sonarqube-${SONAR_VERSION}/bin/linux-x86-64/sonar.sh stop
User=sonar
Group=sonar
Restart=on-failure
LimitNOFILE=131072
LimitNPROC=8192

[Install]
WantedBy=multi-user.target
EOF

echo ">>> Reloading systemd and starting SonarQube..."
systemctl daemon-reload
systemctl enable sonarqube
systemctl start sonarqube

echo ">>> Waiting for startup (60 seconds)..."
sleep 60
systemctl status sonarqube --no-pager

echo ">>> Installation complete!"
echo ">>> Access at http://<your-ec2-public-ip>:9000"
echo ">>> Default login: admin / admin (change on first login)"
