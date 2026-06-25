#!/bin/bash
set -e

echo "========== Starting Setup =========="

sudo apt-get update -y
sudo apt-get upgrade -y

# Java 21 (Jenkins runtime) + Java 17 (pipeline tool)
echo "========== Installing Java =========="
wget -qO - https://packages.adoptium.net/artifactory/api/gpg/key/public | gpg --dearmor | sudo tee /usr/share/keyrings/adoptium.gpg > /dev/null
echo "deb [signed-by=/usr/share/keyrings/adoptium.gpg] https://packages.adoptium.net/artifactory/deb $(awk -F= '/^VERSION_CODENAME/{print$2}' /etc/os-release) main" | sudo tee /etc/apt/sources.list.d/adoptium.list
sudo apt-get update -y
sudo apt-get install -y temurin-21-jdk temurin-17-jdk

# NodeJS 20 (pre-installed so pipeline doesn't download it at runtime)
echo "========== Installing NodeJS 20 =========="
wget -q "https://nodejs.org/dist/v20.17.0/node-v20.17.0-linux-x64.tar.xz" -O /tmp/node.tar.xz
sudo mkdir -p /usr/local/node20
sudo tar -xJf /tmp/node.tar.xz -C /usr/local/node20 --strip-components=1

# Docker
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

# SonarQube (start early so it has time to initialise)
echo "========== Starting SonarQube =========="
docker run -d --name sonar -p 9000:9000 --restart unless-stopped sonarqube:lts-community

# Jenkins WAR
echo "========== Installing Jenkins =========="
sudo mkdir -p /usr/share/jenkins
sudo wget -q -O /usr/share/jenkins/jenkins.war https://get.jenkins.io/war-stable/latest/jenkins.war
sudo useradd -m -s /bin/bash jenkins || true
sudo mkdir -p /var/lib/jenkins
sudo chown jenkins:jenkins /var/lib/jenkins
sudo usermod -aG docker jenkins

# Install all plugins before Jenkins starts
echo "========== Installing Jenkins Plugins =========="
PLUGIN_MGR_URL=$(curl -s https://api.github.com/repos/jenkinsci/plugin-installation-manager-tool/releases/latest \
  | python3 -c "import sys,json; assets=json.load(sys.stdin).get('assets',[]); urls=[a['browser_download_url'] for a in assets if a['name'].endswith('.jar')]; print(urls[0] if urls else '')" 2>/dev/null)
if [ -z "$PLUGIN_MGR_URL" ]; then
  PLUGIN_MGR_URL="https://github.com/jenkinsci/plugin-installation-manager-tool/releases/download/2.12.13/jenkins-plugin-manager-2.12.13.jar"
fi
sudo wget -q -O /usr/share/jenkins/jenkins-plugin-manager.jar "$PLUGIN_MGR_URL"

cat > /tmp/plugins.txt << 'PLUGINS_EOF'
configuration-as-code
git
workflow-aggregator
pipeline-stage-view
sonar
nodejs
docker-workflow
docker-plugin
docker-commons
email-ext
ws-cleanup
adoptopenjdk
job-dsl
github
credentials-binding
PLUGINS_EOF

sudo mkdir -p /var/lib/jenkins/plugins
sudo java -jar /usr/share/jenkins/jenkins-plugin-manager.jar \
  --war /usr/share/jenkins/jenkins.war \
  --plugin-download-directory /var/lib/jenkins/plugins \
  --plugin-file /tmp/plugins.txt
sudo chown -R jenkins:jenkins /var/lib/jenkins/plugins

# JCasC — full Jenkins configuration as code
echo "========== Writing Jenkins Configuration =========="
sudo mkdir -p /var/lib/jenkins/casc_configs

sudo tee /var/lib/jenkins/casc_configs/jenkins.yaml > /dev/null << 'CASC_EOF'
jenkins:
  systemMessage: "Swiggy CI/CD Pipeline — fully configured, ready to use"
  numExecutors: 2

  securityRealm:
    local:
      allowsSignup: false
      users:
        - id: "admin"
          password: "admin"

  authorizationStrategy:
    loggedInUsersCanDoAnything:
      allowAnonymousRead: false

  globalNodeProperties:
    - envVars:
        env:
          - key: "DOCKERHUB_USER"
            value: "navneet117"
          - key: "APP_NAME"
            value: "swiggy"
          - key: "APP_REPO_URL"
            value: "https://github.com/sandeepallakonda/DevOps-Project-Swiggy-sandeep.git"
          - key: "NOTIFICATION_EMAIL"
            value: "viveknavneet117@gmail.com"

tool:
  jdk:
    installations:
      - name: "jdk17"
        home: "/usr/lib/jvm/temurin-17-jdk-amd64"
  nodejs:
    installations:
      - name: "node20"
        home: "/usr/local/node20"
  sonarRunnerInstallation:
    installations:
      - name: "sonar-scanner"
        properties:
          - installSource:
              installers:
                - sonarRunnerInstaller:
                    id: "5.0.1.3006"
  dockerTool:
    installations:
      - name: "docker"
        home: "/usr"

unclassified:
  sonarGlobalConfiguration:
    buildWrapperEnabled: false
    installations:
      - name: "sonar-server"
        serverUrl: "http://localhost:9000"
        credentialsId: "sonar-token"

security:
  globalJobDslSecurityConfiguration:
    useScriptSecurity: false

jobs:
  - script: |
      pipelineJob('Swiggy') {
        definition {
          cpsScm {
            scm {
              git {
                remote {
                  url('https://github.com/RA5C4L/Devops-Swiggy-Pipeline.git')
                }
                branch('*/main')
              }
            }
            scriptPath('jenkins/Jenkinsfile')
          }
        }
        triggers {
          githubPush()
        }
      }
CASC_EOF

sudo chown -R jenkins:jenkins /var/lib/jenkins/casc_configs

# Jenkins systemd service — wizard disabled, JCasC enabled
sudo tee /etc/systemd/system/jenkins.service > /dev/null << 'SERVICE_EOF'
[Unit]
Description=Jenkins Server
After=network.target

[Service]
User=jenkins
ExecStart=/usr/lib/jvm/temurin-21-jdk-amd64/bin/java -Djenkins.install.runSetupWizard=false -jar /usr/share/jenkins/jenkins.war --httpPort=8080
Environment="JENKINS_HOME=/var/lib/jenkins"
Environment="CASC_JENKINS_CONFIG=/var/lib/jenkins/casc_configs"
Restart=on-failure
RestartSec=10

[Install]
WantedBy=multi-user.target
SERVICE_EOF

sudo systemctl daemon-reload
sudo systemctl enable jenkins
sudo systemctl start jenkins

# Trivy
echo "========== Installing Trivy =========="
wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | gpg --dearmor | sudo tee /usr/share/keyrings/trivy.gpg > /dev/null
echo "deb [signed-by=/usr/share/keyrings/trivy.gpg] https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main" | sudo tee /etc/apt/sources.list.d/trivy.list
sudo apt-get update -y
sudo apt-get install trivy -y

# Wait for SonarQube then create Jenkins webhook automatically
echo "========== Configuring SonarQube Webhook =========="
until curl -sf http://localhost:9000/api/system/status 2>/dev/null | python3 -c "import sys,json; exit(0 if json.load(sys.stdin).get('status')=='UP' else 1)" 2>/dev/null; do
  echo "Waiting for SonarQube to be ready..."
  sleep 15
done
curl -s -u admin:admin -X POST "http://localhost:9000/api/webhooks/create" \
  -d "name=jenkins&url=http://172.17.0.1:8080/sonarqube-webhook/" || true
echo "SonarQube webhook created"

echo "========== Setup Complete =========="
