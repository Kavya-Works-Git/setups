# 1. Install Java (Nexus 3.x needs Java 8 or 11 — Java 17 works with recent versions)
apt update
apt install -y openjdk-17-jdk

# 2. Set JAVA_HOME
echo 'export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64' >> ~/.bashrc
source ~/.bashrc

# 3. Download and extract Nexus
cd /opt
wget https://download.sonatype.com/nexus/3/latest-unix.tar.gz
tar -zxvf latest-unix.tar.gz

# 4. Rename extracted folder for a stable path (version-independent)
mv nexus-3* nexus
ls -d sonatype-work || echo "sonatype-work folder created automatically on first run"

# 5. Since you're root, tell Nexus to allow running as root
echo 'run_as_user="root"' > /opt/nexus/bin/nexus.rc

# 6. Start Nexus
/opt/nexus/bin/nexus start

# 7. Check status / logs
/opt/nexus/bin/nexus status
tail -f /opt/nexus/sonatype-work/nexus3/log/nexus.log
