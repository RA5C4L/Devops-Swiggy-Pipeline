#!/bin/bash
set -e

echo "========== Starting Setup =========="

# Update system
sudo apt-get update -y
sudo apt-get upgrade -y

# ========== Install Java 21 ==========
echo "========== Installing Java 21 =========="
wget -qO - https://packages.adoptium.net/artifactory/api/gpg/key/public | gpg --dearmor | sudo tee /usr/share/keyrings/adoptium.gpg > /dev/null
echo "deb [signed-by=/usr/share/keyrings/adoptium.gpg] https://packages.adoptium.net/artifactory/deb $(awk -F= '/^VERSION_CODENAME/{print$2}' /etc/os-release) main" | sudo tee /etc/apt/sources.list.d/adoptium.list
sudo apt-get update -y
sudo apt-get install temurin-21-jdk -y
java -version

# ========== Install Jenkins ==========
echo "========== Installing Jenkins =========="
sudo mkdir -p /usr/share/jenkins
sudo wget -O /usr/share/jenkins/jenkins.war https://get.jenkins.io/war-stable/latest/jenkins.war
sudo useradd -m -s /bin/bash jenkins || true
sudo mkdir -p /var/lib/jenkins
sudo chown jenkins:jenkins /var/lib/jenkins

sudo bash -c 'cat > /etc/systemd/system/jenkins.service << EOF
[Unit]
Description=Jenkins Server
After=network.target

[Service]
User=jenkins
ExecStart=/usr/lib/jvm/temurin-21-jdk-amd64/bin/java -jar /usr/share/jenkins/jenkins.war --httpPort=8080
Environment="JENKINS_HOME=/var/lib/jenkins"
Restart=on-failure
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF'

sudo systemctl daemon-reload
sudo systemctl enable jenkins
sudo systemctl start jenkins
echo "Jenkins started"

# ========== Install Docker ==========
echo "========== Installing Docker =========="
sudo apt-get install -y ca-certificates curl gnupg
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update -y
sudo apt-get install -y docker-ce docker-ce-cli containerd.io
sudo usermod -aG docker ubuntu
sudo chmod 777 /var/run/docker.sock
echo "Docker installed"

# ========== Install SonarQube ==========
echo "========== Starting SonarQube =========="
docker run -d --name sonar -p 9000:9000 --restart unless-stopped sonarqube:lts-community
echo "SonarQube container started"

# ========== Install Trivy ==========
echo "========== Installing Trivy =========="
wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | gpg --dearmor | sudo tee /usr/share/keyrings/trivy.gpg > /dev/null
echo "deb [signed-by=/usr/share/keyrings/trivy.gpg] https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main" | sudo tee /etc/apt/sources.list.d/trivy.list
sudo apt-get update -y
sudo apt-get install trivy -y
echo "Trivy installed"

echo "========== Setup Complete =========="