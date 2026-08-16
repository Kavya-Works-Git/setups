sudo dnf update -y
sudo dnf install java-17-amazon-corretto -y

# Set JAVA_HOME and PATH
echo 'export JAVA_HOME=/usr/lib/jvm/java-17-amazon-corretto.x86_64' | sudo tee /etc/profile.d/java.sh
echo 'export PATH=$JAVA_HOME/bin:$PATH' | sudo tee -a /etc/profile.d/java.sh
source /etc/profile.d/java.sh

# Verify
java -version
