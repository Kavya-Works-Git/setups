# Update system
sudo yum update -y
sudo yum install java-21-amazon-corretto -y

# Verify Java version
java -version

# Add Jenkins repo
sudo wget -O /etc/yum.repos.d/jenkins.repo \
    https://pkg.jenkins.io/rpm-stable/jenkins.repo

# Import Jenkins GPG key
sudo rpm --import https://pkg.jenkins.io/rpm-stable/jenkins.io-2023.key

# Install Jenkins
sudo yum install jenkins -y

# Enable Jenkins service to start on boot
sudo systemctl enable jenkins

# Start Jenkins service
sudo systemctl start jenkins

# Check Jenkins status
sudo systemctl status jenkins
