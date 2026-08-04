#!/bin/bash
set -e

apt update -y
apt install -y openjdk-21-jre-headless

curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2026.key | tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null

echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" | tee /etc/apt/sources.list.d/jenkins.list

apt update -y
apt install -y jenkins

systemctl start jenkins
systemctl enable jenkins
systemctl status jenkins
