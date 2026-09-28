#!/bin/bash
# Install Apache Tomcat on Ubuntu EC2

# Update system
sudo apt update -y
sudo apt upgrade -y

# Install Java (Tomcat requires JDK)
sudo apt install -y default-jdk wget

# Verify Java installation
java -version

# Create Tomcat user (ignore error if already exists)
sudo useradd -m -U -d /opt/tomcat -s /bin/false tomcat || true

# Set Tomcat version
TOMCAT_VERSION=10.1.26

# Download Tomcat from Apache archive
wget https://archive.apache.org/dist/tomcat/tomcat-10/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz -P /tmp

# Extract Tomcat to /opt/tomcat
sudo mkdir -p /opt/tomcat
sudo tar -xzvf /tmp/apache-tomcat-${TOMCAT_VERSION}.tar.gz -C /opt/tomcat --strip-components=1

# Set permissions
sudo chown -R tomcat: /opt/tomcat
sudo chmod +x /opt/tomcat/bin/*.sh

# Create systemd service file
sudo tee /etc/systemd/system/tomcat.service > /dev/null <<EOF
[Unit]
Description=Apache Tomcat Web Application Container
After=network.target

[Service]
Type=forking
User=tomcat
Group=tomcat

Environment="JAVA_HOME=/usr/lib/jvm/java-25-openjdk-amd64"
Environment="CATALINA_HOME=/opt/tomcat"
Environment="CATALINA_BASE=/opt/tomcat"
Environment="CATALINA_PID=/opt/tomcat/temp/tomcat.pid"
Environment="CATALINA_OPTS=-Xms512M -Xmx1024M -server -XX:+UseParallelGC"
Environment="JAVA_OPTS=-Djava.awt.headless=true -Djava.security.egd=file:/dev/./urandom"

ExecStart=/opt/tomcat/bin/startup.sh
ExecStop=/opt/tomcat/bin/shutdown.sh

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd and start Tomcat
sudo systemctl daemon-reload
sudo systemctl enable tomcat
sudo systemctl start tomcat

# Check Tomcat status
systemctl status tomcat
