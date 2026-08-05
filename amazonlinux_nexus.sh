# 1. Install Java
yum update -y
yum install -y java-17-amazon-corretto

# 2. Set JAVA_HOME
echo 'export JAVA_HOME=/usr/lib/jvm/java-17-amazon-corretto' >> ~/.bashrc
source ~/.bashrc

# 3. Download and extract Nexus
cd /opt
wget https://download.sonatype.com/nexus/3/latest-unix.tar.gz
tar -zxvf latest-unix.tar.gz
mv nexus-3* nexus

# 4. Allow running as root
echo 'run_as_user="root"' > /opt/nexus/bin/nexus.rc

# 5. Start Nexus
/opt/nexus/bin/nexus start

# 6. Check status / logs
/opt/nexus/bin/nexus status
tail -f /opt/nexus/sonatype-work/nexus3/log/nexus.log
