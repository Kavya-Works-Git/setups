# 1. Update packages and install Java
apt update
apt install -y openjdk-21-jdk

# 2. Set JAVA_HOME
echo 'export JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64' >> ~/.bashrc
source ~/.bashrc

# 3. Download and extract Tomcat
cd ~
wget https://dlcdn.apache.org/tomcat/tomcat-9/v9.0.120/bin/apache-tomcat-9.0.120.tar.gz
tar -zxvf apache-tomcat-9.0.120.tar.gz

# 4. Create manager user (clean rewrite, avoids XML corruption)
cat > apache-tomcat-9.0.120/conf/tomcat-users.xml << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<tomcat-users xmlns="http://tomcat.apache.org/xml"
              xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
              xsi:schemaLocation="http://tomcat.apache.org/xml tomcat-users.xsd"
              version="1.0">
<role rolename="manager-gui"/>
<role rolename="manager-script"/>
<user username="tomcat" password="admin@123" roles="manager-gui,manager-script"/>
</tomcat-users>
EOF

# 5. Allow remote access to Manager and Host Manager apps
sed -i '/<Valve/,/\/>/d' apache-tomcat-9.0.120/webapps/manager/META-INF/context.xml
sed -i '/<Valve/,/\/>/d' apache-tomcat-9.0.120/webapps/host-manager/META-INF/context.xml

# 6. Start Tomcat
sh apache-tomcat-9.0.120/bin/startup.sh

# 7. Confirm it started
tail -30 apache-tomcat-9.0.120/logs/catalina.out
