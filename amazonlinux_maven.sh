#!/bin/bash
set -e

# Update system
yum update -y

# Install Amazon Corretto JDK 17 (LTS)
yum install -y java-17-amazon-corretto

# Verify Java installation
java -version

# Define Maven version
MAVEN_VERSION=3.9.16
MAVEN_DIR=apache-maven-$MAVEN_VERSION
MAVEN_TAR=$MAVEN_DIR-bin.tar.gz

# Download Maven
cd /tmp
curl -O https://downloads.apache.org/maven/maven-3/$MAVEN_VERSION/binaries/$MAVEN_TAR

# Extract Maven
tar -xvzf $MAVEN_TAR -C /opt/

# Create symlink for convenience
ln -s /opt/$MAVEN_DIR /opt/maven

# Set environment variables
cat > /etc/profile.d/maven.sh <<EOF
export M2_HOME=/opt/maven
export PATH=\$M2_HOME/bin:\$PATH
EOF

# Apply environment variables immediately
source /etc/profile.d/maven.sh

# Verify Maven installation
mvn -version

echo "✅ Maven $MAVEN_VERSION installed successfully on Amazon Linux!"
