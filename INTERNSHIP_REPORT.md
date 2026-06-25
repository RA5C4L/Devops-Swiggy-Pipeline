# Internship Project Report
## End-to-End DevOps CI/CD Pipeline on AWS
### Socedge Technologies, Bangalore

---

## 1. Introduction

This report documents the design, implementation, troubleshooting, and progressive improvement of a complete DevOps CI/CD pipeline built during my software internship at Socedge Technologies. The project involved setting up automated cloud infrastructure and a multi-stage deployment pipeline using industry-standard tools — covering everything from infrastructure provisioning to containerised application delivery.

The pipeline was built to deploy a Node.js web application and serves as a working demonstration of the full DevOps lifecycle: code quality enforcement, security scanning, containerisation, and automated deployment — all triggered by a single git push.

---

## 2. Objectives

- Provision cloud infrastructure on AWS using Infrastructure as Code (Terraform)
- Set up a Jenkins-based CI/CD pipeline with multiple automated stages
- Integrate static code analysis using SonarQube with quality gate enforcement
- Implement container vulnerability scanning using Trivy
- Containerise the application using Docker and publish to a registry
- Automate the full process from code push to live deployment
- Make the pipeline reusable and zero-configuration for new users

---

## 3. Technology Stack

| Tool | Version | Purpose |
|------|---------|---------|
| Terraform | 1.x | Infrastructure as Code — provisions all AWS resources |
| AWS EC2 | c7i-flex.large | Cloud server running the entire pipeline |
| Jenkins | LTS (WAR) | CI/CD orchestration — runs the pipeline |
| SonarQube | LTS Community | Static code analysis and quality gate |
| Trivy | 0.71.x | CVE scanning for source code and Docker images |
| Docker | CE | Application containerisation |
| DockerHub | - | Docker image registry |
| Java | Temurin 21 | Jenkins runtime |
| Node.js | 20.x | Application runtime |

---

## 4. Architecture Overview

The project is structured around a single EC2 instance that hosts the full toolchain:

```
Developer pushes code to GitHub
            |
            v
    GitHub Webhook fires
            |
            v
     Jenkins (port 8080)
            |
     runs 9 pipeline stages:
     1. Clean Workspace
     2. Checkout Source Code
     3. SonarQube Analysis -----> SonarQube (port 9000)
     4. Quality Gate (blocks if fails)
     5. Install Dependencies
     6. Trivy Filesystem Scan
     7. Docker Build & Push -----> DockerHub
     8. Trivy Image Scan
     9. Deploy Container (port 3000)
            |
            v
    Email Notification sent
```

All infrastructure — the EC2 instance, security group, and storage — is defined in Terraform and reproducible with a single command. A startup script (`resource.sh`) installs and configures every tool automatically on first boot.

---

## 5. Implementation

### 5.1 Infrastructure as Code (Terraform)

The infrastructure was defined entirely in Terraform with a modular structure:

**`provider.tf`** — AWS provider configuration with region as a variable.

**`variables.tf`** — All configurable parameters defined with sensible defaults:
- AWS region, instance type, AMI ID
- Key pair name, volume size
- Application port and name

**`main.tf`** — EC2 instance and security group, with all values referencing variables — no hardcoded values anywhere. The security group opens ports 22 (SSH), 80, 443, 8080 (Jenkins), 9000 (SonarQube), and 3000 (application).

**`outputs.tf`** — After `terraform apply`, the following are automatically printed:
- Jenkins URL
- SonarQube URL
- Application URL
- SSH command (ready to use)

This means after provisioning, the engineer has everything needed to connect and operate the server without touching the AWS console.

### 5.2 Server Startup Script (resource.sh)

The EC2 instance runs `resource.sh` automatically on first boot via AWS `user_data`. This script installs and configures the full toolchain without any human involvement:

1. System update and upgrade
2. Java 21 (Temurin) — Jenkins runtime
3. Java 17 (Temurin) — pipeline build tool
4. NodeJS 20 — application dependency
5. Docker — container runtime
6. SonarQube — started as a Docker container
7. Jenkins — downloaded as a WAR file, registered as a systemd service
8. Jenkins plugins — all 15 required plugins pre-installed before Jenkins starts
9. Jenkins configuration — applied via Jenkins Configuration as Code (JCasC)
10. Trivy — installed from official repository
11. SonarQube webhook — created automatically via SonarQube API

### 5.3 Jenkins Pipeline (Jenkinsfile)

The pipeline is defined as a declarative Jenkinsfile with 9 stages:

**Stage 1 — Clean Workspace:** Removes all files from previous builds to ensure a clean state.

**Stage 2 — Checkout from Git:** Pulls the latest application source code from the configured GitHub repository.

**Stage 3 — SonarQube Analysis:** Runs the SonarQube Scanner against the source code. Analyses for bugs, vulnerabilities, code smells, and duplication.

**Stage 4 — Quality Gate:** Pauses and waits for SonarQube to send the analysis result via webhook. If the quality gate fails, the pipeline aborts — nothing gets deployed.

**Stage 5 — Install Dependencies:** Runs `npm install` to fetch all Node.js dependencies.

**Stage 6 — Trivy Filesystem Scan:** Scans the source code and dependencies for known CVEs. Results saved as an artifact accessible from the Jenkins build page.

**Stage 7 — Docker Build and Push:** Builds a Docker image from the application Dockerfile, tags it, and pushes it to DockerHub. Credentials are injected securely at runtime — never stored in any file.

**Stage 8 — Trivy Image Scan:** Scans the published Docker image for vulnerabilities at the container layer level.

**Stage 9 — Deploy to Container:** Removes the old running container and starts a fresh one from the newly built image on port 3000.

**Post stages:** Email notifications are sent on success and failure using the Email Extension plugin. The recipient email is configurable via a Jenkins environment variable.

### 5.4 Jenkins Configuration as Code (JCasC)

To eliminate manual setup and make the pipeline instantly usable after `terraform apply`, the entire Jenkins configuration was codified in a YAML file (`jenkins/jenkins.yaml`):

- Admin user creation
- Global environment variables (DockerHub username, app name, repo URL, notification email)
- Tool installations (JDK 17, NodeJS 20, SonarQube Scanner, Docker)
- SonarQube server connection
- Pipeline job creation (via Job DSL)

This configuration is written to the server by the startup script and loaded by Jenkins automatically on first boot. The result is that Jenkins starts fully configured — no manual browser setup required.

---

## 6. Challenges Encountered and How They Were Resolved

### 6.1 Jenkins GPG Key Failure

**Problem:** The standard Jenkins installation method using the official apt repository was failing due to deprecated GPG key handling in newer Ubuntu versions. The key import step would succeed but apt would reject packages during installation.

**Resolution:** Switched to installing Jenkins via its standalone WAR file directly from the Jenkins download server. The WAR is packaged as a single Java executable and requires no apt repository. A custom systemd service was written to run it. This is actually a more robust approach — it avoids repository dependency entirely and always installs the latest stable release.

### 6.2 Wrong Java Version for Jenkins LTS

**Problem:** The initial setup installed Java 17, but Jenkins LTS requires Java 21 as of recent releases. Jenkins would start but log warnings and certain features behaved unexpectedly.

**Resolution:** Switched the runtime to Temurin 21 JDK. Java 17 was kept separately as a build tool for the pipeline (referenced as `jdk17` in Jenkins Tools), since the application may depend on JDK 17 for builds. The systemd service was updated to explicitly point to the Temurin 21 binary path.

### 6.3 Hardcoded Infrastructure Values

**Problem:** All Terraform resource definitions had hardcoded values — region, instance type, AMI ID, key pair name — making the code specific to one environment and one user. Any change required editing the source files.

**Resolution:** Extracted all configurable values into `variables.tf` with documented descriptions and defaults. `main.tf` references only variable names. Users can now override any value at apply time with `-var="key=value"` or via a `terraform.tfvars` file, without touching the infrastructure code. A `terraform.tfvars.example` file was added to document all available parameters.

### 6.4 No Visibility into Provisioned Resources

**Problem:** After `terraform apply`, there was no easy way to find the instance's IP address, URLs, or SSH command without going into the AWS console.

**Resolution:** Added `outputs.tf` which prints all operational details — Jenkins URL, SonarQube URL, application URL, and a ready-to-use SSH command — immediately after provisioning completes.

### 6.5 Credentials and User-Specific Values Hardcoded in Pipeline

**Problem:** The Jenkinsfile had DockerHub username and GitHub repository URL hardcoded as strings. Any other user wanting to run the pipeline would need to edit the source file.

**Resolution:** Moved all user-specific values to Jenkins Global Properties as environment variables (`DOCKERHUB_USER`, `APP_NAME`, `APP_REPO_URL`, `NOTIFICATION_EMAIL`). The Jenkinsfile reads these at runtime. The Jenkinsfile itself contains zero user-specific values — it only references variable names. Different users configure their values in `jenkins/jenkins.yaml` or Jenkins UI; the pipeline code is identical for everyone.

### 6.6 Complete Manual Jenkins Setup on Every Deployment

**Problem:** Every time the EC2 instance was destroyed and recreated (which is the intended workflow — destroy after use to avoid cost), Jenkins had to be manually reconfigured from scratch. This took 30+ minutes and involved: installing 8 plugins, configuring 4 tools, setting 4 environment variables, connecting SonarQube, creating the pipeline job, and creating the SonarQube webhook.

**Resolution:** Implemented Jenkins Configuration as Code (JCasC). All configuration is defined in `jenkins/jenkins.yaml` and applied automatically when Jenkins starts. All 15 plugins are pre-installed before Jenkins boots using the Jenkins Plugin Installation Manager tool. The SonarQube webhook is created automatically via the SonarQube REST API at the end of the startup script. The entire 30-minute manual setup is now reduced to two steps: adding the SonarQube token credential and the DockerHub credential — both of which require the actual secret values that cannot be stored in a repository.

---

## 7. Key Learnings

### Infrastructure as Code
Terraform taught the discipline of treating infrastructure the same way as application code — versioned, reproducible, and reviewable. The difference between a `variables.tf` (what can change) and `main.tf` (how the infrastructure is structured) reflects the same separation of concerns used in software architecture.

### CI/CD Pipeline Design
Understanding why each stage exists and what it prevents. The quality gate is not just a check — it is a deployment blocker. Trivy running twice (filesystem and image) is intentional: the filesystem scan catches vulnerable library versions in code, while the image scan catches vulnerabilities in the container's OS packages and base image layers that the source scan would miss.

### Credential Security
Credentials in a CI/CD system should never exist in files. Jenkins' credential store encrypts secrets at rest and exposes them only inside the specific pipeline step that needs them, for the duration of that step, and never prints them to logs. The pipeline code only references credential IDs — labels pointing to encrypted storage.

### systemd Service Management
Writing a custom systemd unit file for Jenkins revealed how Linux service management works — how services declare dependencies (`After=network.target`), restart policies (`Restart=on-failure`), environment injection (`Environment=`), and how `systemctl enable` vs `systemctl start` differ (persistence across reboots vs immediate start).

### Docker in a Pipeline Context
Docker is not just a deployment tool in this pipeline — it is used three ways: as the runtime for SonarQube (a third-party service containerised for easy setup), as the build tool for the application image, and as the deployment mechanism. The distinction between `docker build`, `docker tag`, `docker push`, and `docker run` — and why they are separate commands — reflects how Docker separates image creation from distribution from execution.

### Jenkins Configuration as Code (JCasC)
The manual Jenkins setup problem exposed a broader infrastructure principle: any configuration that requires human clicks is a configuration that will drift, be forgotten, or be inconsistent across environments. JCasC applies the same Infrastructure as Code philosophy to application configuration. The final state — where Jenkins boots fully configured with no human involvement — is closer to how production systems are managed at scale.

### Webhook Architecture
Two webhooks are used in the system, in opposite directions. GitHub calls Jenkins when code is pushed (inbound trigger). SonarQube calls Jenkins when analysis is complete (inbound result). Jenkins never polls either system — it reacts to events. This event-driven pattern is significantly more efficient than polling and is the standard approach in production CI/CD systems.

---

## 8. Project Outcomes

- Full CI/CD pipeline operational end-to-end
- Infrastructure provisioned and destroyed on-demand with single commands
- Pipeline auto-triggers on every GitHub push via webhook
- Code quality enforced as a hard deployment gate — bad code cannot be deployed
- Container vulnerability scanning integrated at two levels
- Application containerised, published to DockerHub, and deployed automatically
- Jenkins fully auto-configures on boot — no manual setup required
- Email notifications delivered on pipeline success and failure
- Zero user-specific values in code — fully configurable for any user via `jenkins/jenkins.yaml`
- Complete project documentation provided for independent replication

---

## 9. Repository Structure

```
Devops-Swiggy-Pipeline/
├── terraform/
│   ├── provider.tf          — AWS provider and region
│   ├── main.tf              — EC2 instance and security group
│   ├── variables.tf         — All configurable parameters
│   ├── outputs.tf           — Post-apply URLs and SSH command
│   ├── resource.sh          — Server startup script
│   └── terraform.tfvars.example — Sample configuration for new users
├── jenkins/
│   ├── Jenkinsfile          — 9-stage declarative pipeline
│   ├── jenkins.yaml         — Full Jenkins configuration as code
│   └── plugins.txt          — All required Jenkins plugins
├── PROJECT_GUIDE.md         — Step-by-step setup guide for new users
└── .gitignore               — Excludes tfstate, .terraform/, keys
```

---

## 10. Conclusion

This project covered the full breadth of a modern DevOps workflow — from cloud resource provisioning to automated deployment with integrated security and quality controls. The progressive improvements made throughout — fixing broken installations, eliminating hardcoded values, adding observability through outputs, and finally automating the entire Jenkins configuration — reflect the iterative nature of real engineering work.

The final pipeline requires two manual steps to go from zero to a running deployment: adding credentials. Everything else — servers, configuration, tools, jobs, webhooks — is code.
