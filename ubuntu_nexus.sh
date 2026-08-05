#!/bin/bash
# ============================================
# Nexus Repository OSS Installation Script
# For Ubuntu EC2 instance (run as root)
# Tested and fixed version - Aug 2026
# ============================================

set -e

echo ">>> Updating system packages..."
apt update -y && apt upgrade -y

echo ">>> Installing Java 11 and wget..."
apt install -y openjdk-11-jdk wget
java -version

echo ">>> Creating nexus user..."
useradd -m -d /opt/nexus -s /bin/bash nexus || echo "User already exists"

echo ">>> Downloading Nexus Repository OSS..."
cd /opt
NEXUS_VERSION="3.70.1-02"   # check latest version at https://help.sonatype.com/repomanager3/product-information/download before running
wget https://download.sonatype.com/nexus/3/nexus-${NEXUS_VERSION}-unix.tar.gz -O nexus.tar.gz

echo ">>> Extracting Nexus..."
tar -xvzf nexus.tar.gz
rm nexus.tar.gz
mv nexus-* nexus-installation

echo ">>> Setting ownership for nexus user..."
chown -R nexus:nexus /opt/nexus-installation
chown -R nexus:nexus /opt/sonatype-work

echo ">>> Configuring Nexus to run as nexus user..."
echo 'run_as_user="nexus"' > /opt/nexus-installation/bin/nexus.rc

echo ">>> Fixing known startup issues in nexus.vmoptions..."
# 1. Comment out the endorsed.dirs flag - breaks on Java 9+ (causes "Could not create JVM" error)
sed -i 's/^-Djava.endorsed.dirs=lib\/endorsed/#-Djava.endorsed.dirs=lib\/endorsed/' /opt/nexus-installation/bin/nexus.vmoptions

# 2. Lower heap/memory settings to fit smaller instances (default 2703m needs ~5GB+ RAM)
sed -i 's/-Xms2703m/-Xms1200m/' /opt/nexus-installation/bin/nexus.vmoptions
sed -i 's/-Xmx2703m/-Xmx1200m/' /opt/nexus-installation/bin/nexus.vmoptions
sed -i 's/-XX:MaxDirectMemorySize=2703m/-XX:MaxDirectMemorySize=1200m/' /opt/nexus-installation/bin/nexus.vmoptions

echo ">>> Creating systemd service for Nexus..."
cat > /etc/systemd/system/nexus.service << 'EOF'
[Unit]
Description=Nexus Repository Manager
After=network.target

[Service]
Type=forking
LimitNOFILE=65536
ExecStart=/opt/nexus-installation/bin/nexus start
ExecStop=/opt/nexus-installation/bin/nexus stop
User=nexus
Restart=on-abort

[Install]
WantedBy=multi-user.target
EOF

echo ">>> Reloading systemd and starting Nexus..."
systemctl daemon-reload
systemctl enable nexus
systemctl start nexus

sleep 10
systemctl status nexus --no-pager

echo ">>> Nexus installation complete!"
echo ">>> Access at http://<your-ec2-public-ip>:8081"
echo ">>> Admin password: cat /opt/sonatype-work/nexus3/admin.password"
