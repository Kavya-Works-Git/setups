#!/bin/bash
set -e

# Update system packages
sudo yum update -y

# Install Java 21 (Jenkins requires Java 21 or 25 — 17 is not supported)
sudo yum install -y java-21-amazon-corretto

# Set Java 21 as the system default (critical — prevents Jenkins falling back to an older JDK)
sudo alternatives --install /usr/bin/java java /usr/lib/jvm/java-21-amazon-corretto.x86_64/bin/java 2 2>/dev/null || true
sudo alternatives --set java /usr/lib/jvm/java-21-amazon-corretto.x86_64/bin/java

# Verify
java -version

# Add Jenkins repo
sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key

# Install Jenkins
sudo yum install -y jenkins

# Enable and start
sudo systemctl enable jenkins
sudo systemctl start jenkins

# Wait and check status
sleep 15
sudo systemctl status jenkins --no-pager
