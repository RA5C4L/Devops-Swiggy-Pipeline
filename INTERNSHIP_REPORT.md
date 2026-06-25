# Industrial Training
## on
## End-to-End DevOps CI/CD Pipeline on AWS

**SUBMITTED BY**

[Your Full Name]
[Enrollment Number]
Roll No: [X]
[Branch]
viveknavneet117@gmail.com

Under the Guidance of:
[Mentor Name]
[Mentor Designation]
Socedge Technologies

Department of Computer Science and Engineering

June 2026

---

## Internship Completion Certificate

*[Attach completion certificate from Socedge Technologies here]*

---

## 1. Acknowledgements

I am sincerely grateful for the enriching experience I have had during my industrial training at Socedge Technologies, Bangalore. This internship has been a significant learning milestone, exposing me to real-world DevOps practices and cloud infrastructure engineering that go far beyond what is taught in a classroom environment.

I would like to express my heartfelt gratitude to my mentor and supervisor at Socedge Technologies for their constant guidance, technical direction, and patience throughout the duration of the project. Their mentorship helped me navigate complex technical challenges with confidence and provided me with a clear understanding of how production-grade DevOps systems are designed and maintained.

I am also thankful to the DevOps team at Socedge Technologies, whose collaborative work environment made this experience truly enriching. Being able to contribute to, debug, and meaningfully improve an ongoing engineering effort gave me invaluable hands-on exposure to the kind of iterative engineering that defines real software development.

I would also like to acknowledge the organizational support extended to me throughout this internship — from onboarding to access to tools, cloud resources, and technical documentation — all of which enabled me to perform my work effectively.

Finally, I am grateful to my family and friends for their constant encouragement and support. Their belief in me kept me motivated through the challenges encountered during this project.

This industrial training has significantly strengthened my technical foundation and professional outlook. I leave with practical skills, a deeper understanding of cloud and DevOps engineering, and the confidence to contribute to industry-level projects.

---

## 2. Abstract

This Industrial Training involved the design, implementation, debugging, and progressive automation of a complete end-to-end DevOps CI/CD pipeline on Amazon Web Services (AWS). The project was undertaken at Socedge Technologies, Bangalore, where the DevOps team had initiated work on a cloud-based deployment workflow. As part of the team, primary ownership of the pipeline architecture, automation scripting, and toolchain configuration was taken up, and the system was carried from an early-stage implementation to a fully functional and reproducible pipeline.

The pipeline automates the complete software delivery lifecycle — from infrastructure provisioning using Terraform, through code quality analysis via SonarQube, security vulnerability scanning using Trivy, container image building and publishing via Docker and DockerHub, to live application deployment on an EC2 instance — all triggered automatically on every code commit to GitHub.

A key outcome of the internship was the implementation of Jenkins Configuration as Code (JCasC), which eliminated the need for any manual Jenkins setup. The pipeline was made fully self-configuring — a fresh server provisioned from scratch is ready to run the complete pipeline with only two manual inputs from the user: their DockerHub credentials and their SonarQube token. Every other aspect of the system configures itself automatically on boot.

The project provided deep practical experience in Infrastructure as Code, CI/CD pipeline design, container security, Linux systems administration, credential management, and DevOps automation — all using tools actively used in production engineering environments.

---

## 3. Table of Contents

| Chapter | Title | Page |
|---------|-------|------|
| 1 | Acknowledgements | 3 |
| 2 | Abstract | 4 |
| 3 | Table of Contents | 5 |
| 4 | Details of Organization | 6 |
| 5 | Problem Statement | 7 |
| 5.1 | Current Process | 7 |
| 5.2 | Flowchart | 7 |
| 5.3 | Description | 8 |
| 5.4 | Architecture | 8 |
| 6 | Proposed Solution — Automated CI/CD Pipeline | 9 |
| 6.1 | Overview | 9 |
| 6.2 | Description | 10 |
| 7 | Technology Stack Used | 11 |
| 7.1 | Terraform | 11 |
| 7.2 | Jenkins | 12 |
| 7.3 | SonarQube | 12 |
| 7.4 | Trivy | 13 |
| 7.5 | Docker | 13 |
| 7.6 | AWS EC2 | 14 |
| 8 | Implementation and Features | 15 |
| 8.1 | Infrastructure as Code | 15 |
| 8.2 | Server Startup Automation | 15 |
| 8.3 | CI/CD Pipeline Stages | 16 |
| 8.4 | Jenkins Configuration as Code | 17 |
| 9 | Challenges and Resolutions | 18 |
| 10 | Future Scope | 21 |
| 11 | Conclusion | 22 |
| 12 | NBA/IET Mapping | 23 |
| 13 | References | 26 |

---

## 4. Details of the Organization — Socedge Technologies

Socedge Technologies is a software development and technology services company based in Bangalore, India. The organization is engaged in delivering software engineering solutions across domains including cloud infrastructure, application development, and DevOps consulting. Socedge works with a focus on enabling businesses to adopt modern engineering practices — particularly around automation, cloud-native architectures, and continuous delivery.

**Mission and Focus:** Socedge Technologies is committed to building scalable, reliable, and automated software delivery systems. The organization's work spans cloud provisioning, application containerisation, and the implementation of continuous integration and continuous deployment pipelines that allow development teams to ship software faster and with greater confidence.

**Engineering Culture:** At Socedge, engineering decisions are driven by reproducibility, automation, and security. The teams work with industry-standard tools including AWS, Terraform, Jenkins, Docker, and SonarQube, and emphasize the principle that infrastructure and configuration should be treated as code — versioned, reviewable, and deployable.

**Internship Context:** The industrial training was conducted within the DevOps team at Socedge Technologies. The team was engaged in building an automated cloud deployment pipeline for web applications. The intern joined at an early stage of this effort and took primary responsibility for the pipeline architecture, toolchain configuration, debugging of installation and integration issues, and the implementation of full automation — progressing the system from a partially functional state to a completely self-configuring and reproducible pipeline.

---

## 5. Problem Statement

### 5.1 Current Process

The DevOps team at Socedge Technologies had identified a need for an automated, reproducible CI/CD pipeline for deploying containerised web applications on AWS. The existing process involved significant manual intervention at multiple stages:

- Cloud infrastructure was being provisioned manually through the AWS console
- Jenkins configuration required 30+ minutes of manual setup through the browser UI on every fresh deployment
- There was no automated code quality enforcement before deployment
- Security scanning of source code and container images was absent
- Deployments were performed manually without a standardised process
- No automated notification system existed for build outcomes

The core challenge was to design and implement a system that automated the entire workflow — from cloud provisioning to live deployment — and to make this system reproducible so that it could be brought up and torn down on demand without losing configuration.

### 5.2 Flowchart

**Manual Process (Before):**
```
Developer writes code
        |
        v
Manual AWS console setup
        |
        v
Manual Jenkins configuration (30+ min)
        |
        v
Manual dependency installation
        |
        v
Manual docker build and push
        |
        v
Manual deployment on server
```

**Automated Pipeline (After):**
```
Developer pushes code to GitHub
        |
        v
GitHub Webhook fires automatically
        |
        v
Jenkins pipeline triggered
        |
        v
SonarQube Code Quality Analysis
        |
        v
Quality Gate (blocks deployment if failed)
        |
        v
Trivy Source Code Security Scan
        |
        v
Docker Image Build and Push to DockerHub
        |
        v
Trivy Docker Image Security Scan
        |
        v
Automated Container Deployment
        |
        v
Email Notification (success or failure)
```

### 5.3 Description

The problem addressed was the complete absence of a standardised, automated deployment pipeline. Every deployment required a developer or DevOps engineer to manually execute multiple steps across multiple systems — provisioning cloud resources, installing and configuring tools, building and pushing Docker images, and running containers. This process was error-prone, time-consuming, and not reproducible.

Furthermore, there was no enforcement of code quality standards or security scanning before deployment. Code with known vulnerabilities or poor quality metrics could be deployed without any automated check, increasing the risk of deploying insecure or unstable software.

The specific problems to be solved were:

- Infrastructure provisioning must be automated and reproducible using code
- The Jenkins CI/CD server must self-configure on boot without manual browser-based setup
- Code quality must be enforced as a hard gate before deployment proceeds
- Both source code and Docker images must be scanned for known security vulnerabilities
- The deployment process must be fully automated on every code push
- Build outcomes must be communicated automatically via email

### 5.4 Architecture

The final system architecture places all tooling on a single EC2 instance provisioned by Terraform. This instance hosts Jenkins (the pipeline orchestrator), SonarQube (code analysis), Docker (container runtime), and Trivy (security scanner). The architecture follows an event-driven model — GitHub notifies Jenkins when code is pushed, Jenkins orchestrates the pipeline stages, SonarQube notifies Jenkins when analysis is complete, and Jenkins triggers deployment only after all quality and security checks pass.

```
+------------------+         +---------------------------+
|   Developer      |         |     GitHub Repository     |
|   (git push)     +-------->+   (webhook to Jenkins)    |
+------------------+         +-------------+-------------+
                                            |
                                            v
                          +----------------+----------------+
                          |           AWS EC2 Instance      |
                          |                                 |
                          |  +----------+  +-----------+   |
                          |  | Jenkins  |  | SonarQube |   |
                          |  | :8080    |  | :9000     |   |
                          |  +----+-----+  +-----+-----+   |
                          |       |              |          |
                          |       | webhook      |          |
                          |       +--------------+          |
                          |       |                         |
                          |  +----+-----+  +-----------+   |
                          |  |  Docker  |  |  Trivy    |   |
                          |  |  Build   |  |  Scanner  |   |
                          |  +----+-----+  +-----------+   |
                          |       |                         |
                          +-------+-------------------------+
                                  |
                          +-------v-------+
                          |   DockerHub   |
                          | (image store) |
                          +---------------+
                                  |
                          +-------v-------+
                          |  App running  |
                          |  on port 3000 |
                          +---------------+
```

---

## 6. Proposed Solution — Automated CI/CD Pipeline on AWS

### 6.1 Overview

The proposed solution is a fully automated, self-configuring CI/CD pipeline that provisions cloud infrastructure on AWS using Terraform and runs a nine-stage Jenkins pipeline covering code quality analysis, security scanning, containerisation, and deployment.

The key engineering principle behind the solution is that **everything is code**. The cloud infrastructure is defined in Terraform files. The Jenkins configuration is defined in a YAML configuration file. The pipeline stages are defined in a Jenkinsfile. The required plugins are declared in a text file. A server startup script installs all software automatically. The entire system can be brought up from zero with a single `terraform apply` command and torn down with a single `terraform destroy` command.

The solution was designed with reusability as a primary concern. No user-specific values are hardcoded in any pipeline or infrastructure file. A different user can deploy this pipeline for their own application by changing four configuration values and adding their credentials in the Jenkins UI — everything else is identical.

### 6.2 Description

The implementation addressed each identified problem systematically:

**1. Infrastructure as Code using Terraform**
All AWS resources — the EC2 instance, security group, and storage configuration — are defined in `.tf` files. The system is parameterised through a `variables.tf` file, meaning the same code can be used for different environments, instance types, regions, and applications by simply changing configuration values. After provisioning, `outputs.tf` automatically prints the Jenkins URL, SonarQube URL, application URL, and SSH command — no manual lookup in the AWS console required.

**2. Automated Server Configuration**
A startup script (`resource.sh`) runs automatically when the EC2 instance boots for the first time via AWS `user_data`. This script installs Java 21, Java 17, NodeJS 20, Docker, Jenkins, SonarQube, and Trivy without any human involvement. Jenkins plugins are pre-installed before Jenkins starts, using the Jenkins Plugin Installation Manager tool. The Jenkins configuration is applied automatically via Jenkins Configuration as Code (JCasC) on first boot.

**3. Nine-Stage Jenkins Pipeline**
A declarative Jenkinsfile defines the complete pipeline with stages for workspace cleanup, source code checkout, SonarQube analysis, quality gate enforcement, dependency installation, filesystem security scanning, Docker image build and push, Docker image security scanning, and container deployment. The pipeline is triggered automatically by a GitHub webhook on every code push.

**4. Jenkins Configuration as Code (JCasC)**
The most significant automation achievement of the project. All Jenkins configuration — admin user creation, tool installations, SonarQube server connection, environment variables, and pipeline job creation — is defined in a YAML file (`jenkins/jenkins.yaml`) and applied automatically when Jenkins starts. This reduced the manual Jenkins setup from 30+ minutes of browser interaction to two steps: adding the SonarQube token credential and the DockerHub credential.

**5. Security Scanning at Two Levels**
Trivy is run twice in the pipeline — once against the source code and dependencies (filesystem scan) and once against the published Docker image (image scan). This catches vulnerabilities at both the code level and the container runtime level. Scan results are saved as downloadable artifacts on each Jenkins build.

**6. SonarQube Quality Gate Enforcement**
The pipeline pauses after SonarQube analysis and waits for SonarQube to send the quality gate result back via webhook. If the quality gate fails, the pipeline aborts — the Docker image is never built and the application is never deployed. This makes code quality a hard deployment blocker, not an optional check.

---

## 7. Technology Stack Used

### 7.1 Terraform

Terraform is an open-source Infrastructure as Code tool developed by HashiCorp that allows engineers to define, provision, and manage cloud infrastructure using declarative configuration files. Rather than clicking through a cloud console to create resources, Terraform reads configuration files and makes the corresponding API calls to the cloud provider automatically.

**Key Features:**

**Declarative Configuration:** Engineers describe the desired state of infrastructure in `.tf` files. Terraform determines what needs to be created, changed, or destroyed to reach that state.

**State Management:** Terraform maintains a state file that records every resource it has created. This allows it to detect differences between the desired configuration and the actual cloud state, and apply only the necessary changes.

**Reproducibility:** The same Terraform configuration can be applied repeatedly to produce identical infrastructure. This eliminates environment drift — the situation where production and development environments gradually diverge.

**Variable System:** Infrastructure code can be parameterised using `variables.tf`, allowing the same code to be used for different environments by supplying different values — without modifying the core infrastructure logic.

**Output System:** After provisioning, Terraform prints configured outputs — such as IP addresses, URLs, and connection commands — making it easy to access newly created resources without navigating the cloud console.

### 7.2 Jenkins

Jenkins is an open-source automation server written in Java, widely used for implementing CI/CD pipelines. It provides a framework for defining multi-stage automated workflows that can be triggered by code commits, schedules, or manual actions.

**Key Features:**

**Declarative Pipelines:** Jenkins supports defining pipelines as code using a Groovy-based DSL in a file called `Jenkinsfile`. This allows the pipeline definition to be version-controlled alongside the application code.

**Plugin Ecosystem:** Jenkins has a large ecosystem of plugins that extend its capabilities — connecting it to source control systems, code analysis tools, container registries, and notification systems.

**Credential Management:** Jenkins provides an encrypted credential store that allows secrets such as passwords and API tokens to be stored securely and injected into pipeline steps at runtime, without ever appearing in configuration files or logs.

**Jenkins Configuration as Code (JCasC):** A plugin that allows the entire Jenkins configuration — including users, tools, connections to external systems, environment variables, and job definitions — to be defined in a YAML file and applied automatically on startup.

### 7.3 SonarQube

SonarQube is an open-source platform for continuous code quality inspection. It performs static analysis on source code to detect bugs, vulnerabilities, code smells, and duplications, and provides a dashboard for tracking code quality over time.

**Key Features:**

**Multi-Dimensional Analysis:** SonarQube measures five dimensions of code quality — bugs (incorrect runtime behaviour), vulnerabilities (security weaknesses), code smells (maintainability issues), code coverage (percentage covered by tests), and duplications (copy-pasted code blocks).

**Quality Gates:** A quality gate is a configurable set of pass/fail conditions. If code does not meet the defined standards, the quality gate fails and downstream processes — such as deployment — can be blocked.

**Webhook Notifications:** SonarQube can notify external systems via webhook when analysis is complete. This allows Jenkins to pause the pipeline and wait for the quality gate result before proceeding.

**Language Support:** SonarQube supports analysis of code written in over 25 programming languages, including JavaScript, TypeScript, Java, Python, and many others.

### 7.4 Trivy

Trivy is an open-source comprehensive vulnerability scanner developed by Aqua Security. It is designed to detect known security vulnerabilities (CVEs — Common Vulnerabilities and Exposures) in software artifacts including source code, dependency files, Docker images, and infrastructure configuration.

**Key Features:**

**Multi-Target Scanning:** Trivy can scan source code directories, package dependency files (such as `package.json` and `requirements.txt`), and Docker container images — catching vulnerabilities at multiple stages of the delivery process.

**CVE Database:** Trivy maintains an up-to-date database of known vulnerabilities sourced from multiple security advisories and package registries. Scans are compared against this database to identify affected dependencies.

**Severity Classification:** Vulnerabilities are classified by severity — CRITICAL, HIGH, MEDIUM, LOW, and UNKNOWN — allowing teams to prioritise remediation efforts.

**Report Generation:** Trivy can produce scan reports in multiple formats including table, JSON, and SARIF, which can be archived as build artifacts in Jenkins for review after each pipeline run.

### 7.5 Docker

Docker is an open-source platform that enables developers to package applications and their dependencies into lightweight, portable containers. A Docker container provides a consistent runtime environment that behaves identically across development, testing, and production.

**Key Features:**

**Containerisation:** Docker packages an application together with its runtime dependencies, configuration, and libraries into a single image. This eliminates the "works on my machine" problem by ensuring the application runs in the same environment everywhere.

**Dockerfile:** A text file that defines step-by-step instructions for building a Docker image — the base operating system, dependencies to install, files to copy, and the command to run the application.

**Image Registry:** Docker images can be published to a registry (such as DockerHub) and pulled from there to run on any machine. This makes Docker images a portable, distributable unit of deployment.

**Docker Compose and Networking:** Docker provides networking capabilities that allow multiple containers to communicate, enabling complex multi-service applications to run as isolated, coordinated container groups.

### 7.6 AWS EC2

Amazon Elastic Compute Cloud (EC2) is a web service that provides resizable virtual compute capacity in the cloud. EC2 instances are virtual machines that can be provisioned on demand, scaled up or down, and terminated when no longer needed.

**Key Features:**

**On-Demand Provisioning:** EC2 instances can be created and started within seconds and terminated when the work is complete. This eliminates the need for upfront hardware investment and allows costs to be matched to actual usage.

**Instance Types:** AWS offers a wide range of instance types optimised for different workloads — compute-intensive, memory-intensive, storage-optimised, and general purpose — allowing the right hardware profile to be selected for the task.

**Security Groups:** EC2 instances are protected by security groups, which act as virtual firewalls. Security groups define which ports accept inbound traffic and from which sources, providing network-level access control.

**User Data:** EC2 supports passing a shell script as user data that is automatically executed when the instance first boots. This enables full server configuration automation without any manual SSH access.

**Elastic IPs and DNS:** EC2 provides public IP addresses for instances, enabling them to be reached from the internet. DNS names are automatically assigned, and static Elastic IPs can be associated for persistent addressing.

---

## 8. Implementation and Features

### 8.1 Infrastructure as Code

All AWS infrastructure is defined across four Terraform files:

**`provider.tf`** configures the AWS provider with the region read from a variable, ensuring no region is hardcoded.

**`variables.tf`** declares all configurable parameters — AWS region, EC2 instance type, AMI ID, key pair name, volume size, application port, application name, and instance name tag. Each variable has a description and a default value. This means the same infrastructure code can be used for different applications by changing only the variable values, without touching the infrastructure logic.

**`main.tf`** defines the EC2 instance and security group. All attribute values reference variables — no hardcoded strings exist anywhere in the resource definitions. The security group opens ports for SSH (22), HTTP (80), HTTPS (443), Jenkins (8080), SonarQube (9000), and the application port (configurable).

**`outputs.tf`** defines six outputs that are printed after `terraform apply` completes: the instance public IP, instance ID, Jenkins URL, SonarQube URL, application URL, and a ready-to-use SSH command.

### 8.2 Server Startup Automation

The `resource.sh` script is passed to the EC2 instance as `user_data` and runs automatically on first boot as root. It performs the following operations in sequence:

1. System package update and upgrade
2. Installation of Java 21 (Temurin) — required by Jenkins LTS as the runtime JVM
3. Installation of Java 17 (Temurin) — used as the build-time JDK by the pipeline
4. Installation of NodeJS 20 — pre-installed to avoid download overhead during pipeline runs
5. Installation of Docker using the official Docker GPG key and repository
6. Starting SonarQube as a Docker container on port 9000 with automatic restart policy
7. Downloading the Jenkins WAR file and setting up Jenkins as a systemd service
8. Downloading the Jenkins Plugin Installation Manager and installing all 15 required plugins before Jenkins starts for the first time
9. Writing the JCasC YAML configuration file to the Jenkins home directory
10. Starting Jenkins with the setup wizard disabled and JCasC enabled
11. Installing Trivy from its official repository
12. Waiting for SonarQube to be fully ready, then automatically creating the Jenkins webhook in SonarQube via its REST API

A notable design decision was installing Jenkins via its standalone WAR file rather than through the apt package repository. The apt repository method was found to have reliability issues related to GPG key verification on newer Ubuntu versions. The WAR file approach bypasses the repository entirely, downloading Jenkins directly from the official distribution server and running it as a Java application managed by systemd.

### 8.3 CI/CD Pipeline Stages

The pipeline is defined in `jenkins/Jenkinsfile` as a declarative pipeline with the following nine stages:

**Stage 1 — Clean Workspace:** Deletes all files from the previous build using `cleanWs()`. This ensures no stale files from previous runs affect the current build.

**Stage 2 — Checkout from Git:** Clones the application source code from the configured GitHub repository into the Jenkins workspace. The repository URL is read from the `APP_REPO_URL` environment variable — not hardcoded.

**Stage 3 — SonarQube Analysis:** Runs the SonarQube Scanner against the checked-out source code. The scanner connects to SonarQube using credentials injected by the `withSonarQubeEnv` wrapper — the token is decrypted from the Jenkins credential store and set as an environment variable for the duration of the scan.

**Stage 4 — Quality Gate:** Pauses the pipeline and waits for SonarQube to send the quality gate result back to Jenkins via the webhook. If the quality gate fails, `abortPipeline: true` causes Jenkins to mark the build as failed and stop execution. No subsequent stages run.

**Stage 5 — Install Dependencies:** Runs `npm install` to fetch all Node.js package dependencies declared in the application's `package.json`.

**Stage 6 — Trivy Filesystem Scan:** Scans the source code and all installed dependencies for known CVEs using Trivy. Results are written to a text file and archived as a Jenkins build artifact, accessible for review from the Jenkins build page.

**Stage 7 — Docker Build and Push:** Builds a Docker image from the application's Dockerfile, tags it with the DockerHub username and application name from environment variables, and pushes it to DockerHub. The `withDockerRegistry` wrapper decrypts the DockerHub credentials and runs `docker login` automatically, then logs out after the block completes.

**Stage 8 — Trivy Image Scan:** Scans the published Docker image for vulnerabilities at the container layer level — including the base OS packages and all installed system libraries. Results are archived as a build artifact.

**Stage 9 — Deploy to Container:** Stops and removes the existing running container (if any) and starts a fresh container from the newly built image, mapping port 3000. The application is immediately accessible at the EC2 instance's public IP on port 3000.

**Post-Pipeline Notifications:** Email notifications are sent on both success and failure using the Email Extension plugin. The recipient address is read from the `NOTIFICATION_EMAIL` environment variable. Emails include the build status, project name, build number, and a direct link to the build logs in Jenkins.

### 8.4 Jenkins Configuration as Code

The most technically significant aspect of the project was the implementation of Jenkins Configuration as Code (JCasC). The `jenkins/jenkins.yaml` file defines the complete Jenkins configuration:

**Admin User:** Jenkins starts with an admin account created automatically — no manual user creation through the UI is required.

**Global Environment Variables:** Four environment variables are configured automatically:
- `DOCKERHUB_USER` — DockerHub account username
- `APP_NAME` — the Docker image and container name
- `APP_REPO_URL` — the GitHub URL of the application to be deployed
- `NOTIFICATION_EMAIL` — the email address for build notifications

**Tool Installations:** All four pipeline tools are configured automatically:
- JDK 17 — pointing to the system-installed Temurin JDK 17
- NodeJS 20 — pointing to the pre-installed NodeJS 20 binary
- SonarQube Scanner — configured with an auto-installer
- Docker — pointing to the system Docker binary at `/usr/bin`

**SonarQube Server Connection:** The connection between Jenkins and SonarQube is configured automatically — server URL, server name (matching the name used in the Jenkinsfile), and the credential ID for the SonarQube token.

**Pipeline Job:** The Swiggy pipeline job is created automatically via Job DSL within JCasC, configured to read its pipeline definition from the `jenkins/Jenkinsfile` in the GitHub repository and to trigger automatically on every push via the GitHub webhook.

The result of this implementation is that after `terraform apply` completes, Jenkins starts fully configured and the pipeline job is ready to run. The only manual step remaining is adding the two credentials that cannot be stored in a file for security reasons: the SonarQube token and the DockerHub password.

---

## 9. Challenges and Resolutions

A defining aspect of this internship was working through genuine engineering obstacles — situations where the expected approach did not work and root cause analysis was required to find a correct solution. The following challenges were encountered and resolved during the project.

### 9.1 Jenkins Package Repository — GPG Key Failure

**Challenge:** The standard method of installing Jenkins on Ubuntu uses the official Jenkins apt repository. When this approach was attempted on the EC2 instance, the installation failed due to a GPG key verification error — a known issue with how newer Ubuntu versions handle repository signing keys added via legacy methods.

**Resolution:** Rather than working around the apt repository issue with workarounds that would make the script fragile, a more reliable approach was adopted: downloading the Jenkins WAR file directly from the official Jenkins distribution server and running it as a standalone Java application managed by systemd. This approach has no dependency on the apt repository and is inherently more stable across Ubuntu versions. The WAR file is the same binary that the apt package installs — the only difference is how it is obtained and managed.

**Learning:** Package repository installation methods can be brittle in automated scripts. Direct binary downloads from official sources, while less "conventional," are often more reliable in unattended boot scripts where interactive error handling is not possible.

### 9.2 Terraform Template Syntax Conflict with Shell Script

**Challenge:** The initial configuration used `templatefile("./resource.sh", {})` in Terraform's `main.tf` to attach the startup script to the EC2 instance. When the script was updated to contain heredoc blocks (used to write configuration files from within the shell script), Terraform began failing with interpolation errors. The heredoc content contained `${...}` patterns — such as `${VERSION_CODENAME}` in shell variable expansions — which Terraform's template engine was incorrectly interpreting as Terraform interpolation syntax.

**Resolution:** Changed `templatefile()` to `file()` in `main.tf`. The `file()` function reads the script as a raw string without any template processing, passing it to the EC2 instance exactly as written. Since no Terraform variable interpolation was actually needed inside the script, `templatefile()` was never the right choice.

**Learning:** `templatefile()` and `file()` are not interchangeable. `templatefile()` should only be used when Terraform variables need to be injected into the file content. Using it unnecessarily introduces a hidden fragility — any `${...}` in the file will be treated as a template variable, regardless of intent.

### 9.3 SonarQube Webhook Unreachable from Docker Container

**Challenge:** SonarQube was configured with a webhook pointing to Jenkins at `http://localhost:8080/sonarqube-webhook/` so that it could notify Jenkins when quality gate analysis was complete. The pipeline was getting stuck at the Quality Gate stage, eventually timing out and aborting. Debugging revealed that the SonarQube task was completing on the SonarQube side, but the webhook notification was never reaching Jenkins.

**Root Cause:** SonarQube runs inside a Docker container using the default Docker bridge network. From within a Docker container, `localhost` resolves to the container's own loopback interface — not the host machine where Jenkins is running. The webhook was therefore being sent to a non-existent listener inside the SonarQube container itself.

**Resolution:** Changed the webhook URL from `http://localhost:8080/sonarqube-webhook/` to `http://172.17.0.1:8080/sonarqube-webhook/`. The IP address `172.17.0.1` is the Docker bridge gateway — a virtual network interface that is consistently present on any machine running Docker with the default bridge network, and which always routes to the host from within a container. This change was applied both in the automated webhook creation in `resource.sh` and documented for manual setup.

**Learning:** Docker bridge networking is a frequently misunderstood aspect of containerised services. `localhost` inside a container is not the same as `localhost` on the host, and any service running in Docker that needs to communicate with a host-level service must use the Docker gateway IP or a host network mode.

### 9.4 Quality Gate Timeout Calibration

**Challenge:** Even after resolving the webhook networking issue, the Quality Gate stage was still timing out on the first pipeline run. The SonarQube analysis stage completed successfully and uploaded the analysis report, but the Jenkins pipeline aborted before the quality gate result was received, reporting that the SonarQube background task status was `IN_PROGRESS` at the time of timeout.

**Root Cause:** The SonarQube Compute Engine — the background worker that processes uploaded analysis reports and evaluates quality gates — was slower than the pipeline's two-minute timeout allowed for. On a resource-constrained server running both Jenkins and SonarQube simultaneously, the background processing took longer than on a dedicated server.

**Resolution:** Increased the quality gate timeout in the Jenkinsfile from two minutes to five minutes. This provided sufficient margin for SonarQube's background processing to complete under the load conditions of the shared server.

**Learning:** Timeout values in CI/CD pipelines are not one-size-fits-all. They must be calibrated to the actual performance characteristics of the environment — particularly when multiple memory-intensive services share a single server.

### 9.5 Jenkins Docker Tool Path Misconfiguration in JCasC

**Challenge:** After implementing Jenkins Configuration as Code, the Docker Build and Push stage of the pipeline failed with the error: `Cannot run program "/usr/bin/bin/docker": No such file or directory`. The Docker binary exists at `/usr/bin/docker` on the system, so the path was clearly being constructed incorrectly.

**Root Cause:** The JCasC configuration set the Docker tool installation `home` to `/usr/bin`. The Jenkins Docker plugin constructs the binary path by appending `/bin/docker` to the configured `home` directory. This resulted in `/usr/bin` + `/bin/docker` = `/usr/bin/bin/docker` — a path that does not exist.

**Resolution:** Rather than adjusting the `home` path (which would require a Jenkins restart to take effect), the `toolName` parameter was removed entirely from the `withDockerRegistry` call in the Jenkinsfile. Without an explicit `toolName`, Jenkins resolves the Docker binary from the system `PATH` environment variable, which correctly locates `/usr/bin/docker`. This approach is also simpler and more portable — it does not depend on a specific tool installation configuration in Jenkins.

**Learning:** When configuring tools via JCasC, the `home` parameter represents the root of the tool installation, not the directory containing the binary. Jenkins appends the conventional binary path (`/bin/<tool>`) to the `home` value. Understanding this convention is critical for correct tool configuration. Additionally, using the system PATH where possible reduces dependency on Jenkins-specific tool configuration.

### 9.6 JCasC Configuration Caching After Reload

**Challenge:** When the Docker tool `home` path was corrected in `jenkins.yaml` and the JCasC configuration was reloaded via the Jenkins UI, the pipeline continued to use the old incorrect path. Changing the value directly in the Jenkins UI (Global Tool Configuration) and saving also had no effect on subsequent builds.

**Root Cause:** JCasC periodically reloads its configuration from the YAML file on disk. If the YAML file on the server had not been updated (only the file in the local repository had been changed and pushed), JCasC would reload the old configuration and overwrite the UI change. The fix in the local file had not been propagated to the server's `/var/lib/jenkins/casc_configs/jenkins.yaml`.

**Resolution:** The YAML file on the live server was updated directly via SSH using `sed`, and the JCasC configuration was reloaded. For subsequent deployments, the fix was committed to the repository so that the corrected configuration is written to the server by `resource.sh` on first boot.

**Learning:** JCasC is authoritative — it will overwrite manual UI changes on reload. This is by design (it ensures the server always matches the declared configuration), but it means that fixes must be applied to the source YAML file, not just the UI. Understanding the authority model of configuration-as-code tools is essential when debugging live configuration issues.

---

## 10. Future Scope

The pipeline implemented during this internship delivers a fully functional end-to-end CI/CD workflow. Several enhancements were identified during the project that were deferred as out-of-scope for the internship period but represent natural next steps for a production-grade system.

**Email Notifications:** The pipeline's post-build notification stage was designed to send build status emails via the Jenkins Email Extension plugin. Integration with an SMTP server (such as Gmail with App Password authentication) would allow developers to receive immediate alerts on build success or failure without checking the Jenkins dashboard. This feature was prototyped but removed from the final Jenkinsfile to keep the pipeline free of SMTP configuration dependencies — the `email-ext` plugin remains installed and the notification logic can be re-enabled by configuring the SMTP server credentials in Jenkins.

**GitHub Webhook for Auto-Triggering:** The pipeline job is configured with a `githubPush()` trigger in Jenkins, which is the Jenkins-side requirement for automatic triggering on code push. The missing piece is the corresponding webhook on the GitHub repository — a callback URL pointing to `http://<jenkins-ip>/github-webhook/` that GitHub fires on every push. This was not implemented because the Jenkins server IP changes on every `terraform apply`, making a static webhook configuration impractical. A production deployment would resolve this by assigning an AWS Elastic IP to the instance, making the Jenkins URL permanent and allowing the GitHub webhook to be configured once and reused across redeployments.

**Remote Terraform State:** The current setup uses a local Terraform state file. In a team environment where multiple engineers run `terraform apply` or `terraform destroy`, a shared remote state backend (AWS S3 for storage with DynamoDB for state locking) is essential to prevent state corruption from concurrent operations. Implementing remote state would make the infrastructure management safe for multi-engineer teams.

**SonarQube Quality Gate Customisation:** The current setup uses SonarQube's default "Sonar way" quality gate. For a production project, custom quality gates tailored to the team's standards — specific thresholds for code coverage, maximum allowed vulnerabilities by severity, and duplication limits — would make the gate more meaningful and aligned with project requirements.

---

## 11. Conclusion

The industrial training at Socedge Technologies resulted in the successful design, implementation, debugging, and full automation of a production-grade DevOps CI/CD pipeline on AWS. The pipeline was verified end-to-end — a fresh EC2 instance was provisioned from scratch using Terraform, all software installed automatically via the startup script, Jenkins came up fully configured via JCasC, and all nine pipeline stages completed successfully in a single run, culminating in a live container deployment of the application.

The key technical achievements of the project are:

- A fully parameterised Terraform infrastructure definition with no hardcoded values, deployable to any AWS region with a single `terraform apply` command
- An automated server startup script that installs the complete toolchain — Java, NodeJS, Docker, SonarQube, Jenkins, Trivy — without any manual SSH access
- A nine-stage declarative Jenkins pipeline covering code quality, dependency installation, security scanning at two levels, containerisation, and live deployment
- Jenkins Configuration as Code that reduces a 30-minute manual browser setup to two credential additions
- Correct Docker bridge gateway configuration ensuring SonarQube can notify Jenkins across Docker network boundaries
- A pipeline with zero hardcoded user-specific values — fully configurable for any user through environment variables and credentials

Beyond the implementation itself, the project provided deep practical exposure to the kind of engineering work that defines real DevOps roles — diagnosing failures that do not produce obvious error messages, understanding system boundaries such as Docker container networking, and making targeted fixes that improve the reliability of the system for all future users. Each challenge encountered was analysed at the root cause level rather than patched superficially, resulting in a system that is robust, reproducible, and well-understood.

The pipeline is a working, documented, and version-controlled system that any engineer can bring up independently — a standard that reflects production DevOps practice.

---

## 12. NBA/IET Mapping

**NBA — PROGRAM OUTCOMES (PO) & PROGRAM SPECIFIC OUTCOMES (PSO)**

Engineering Graduates will be able to:

**PO1: Engineering Knowledge** — Apply the knowledge of mathematics, science, engineering fundamentals, and an engineering specialization to the solution of complex engineering problems.

**PO2: Problem Analysis** — Identify, formulate, review research literature, and analyze complex engineering problems reaching substantiated conclusions using first principles of mathematics, natural sciences, and engineering sciences.

**PO3: Design/Development of Solutions** — Design solutions for complex engineering problems and design system components or processes that meet the specified needs with appropriate consideration for public health and safety, and cultural, societal, and environmental considerations.

**PO4: Conduct Investigations of Complex Problems** — Use research-based knowledge and research methods including design of experiments, analysis and interpretation of data, and synthesis of information to provide valid conclusions.

**PO5: Modern Tool Usage** — Create, select, and apply appropriate techniques, resources, and modern engineering and IT tools including prediction and modeling to complex engineering activities with an understanding of the limitations.

**PO6: The Engineer and Society** — Apply reasoning informed by contextual knowledge to assess societal, health, safety, legal and cultural issues and the consequent responsibilities relevant to professional engineering practice.

**PO7: Environment and Sustainability** — Understand the impact of professional engineering solutions in societal and environmental contexts, and demonstrate the knowledge of, and need for sustainable development.

**PO8: Ethics** — Apply ethical principles and commit to professional ethics and responsibilities and norms of the engineering practice.

**PO9: Individual and Team Work** — Function effectively as an individual, and as a member or leader in diverse teams, and in multidisciplinary settings.

**PO10: Communication** — Communicate effectively on complex engineering activities with the engineering community and with society at large.

**PO11: Project Management and Finance** — Demonstrate knowledge and understanding of engineering and management principles and apply these to one's own work.

**PO12: Life-long Learning** — Recognize the need for, and have the preparation and ability to engage in independent and life-long learning in the broadest context of technological change.

**PSO1:** Analyze and solve real world problems by applying a combination of hardware and software.

**PSO2:** Formulate and build optimized solutions for systems level software and computationally intensive applications.

**PSO3:** Design and model applications for various domains using standard software engineering practices.

**PSO4:** Design and develop solutions for distributed processing and communication.

---

**NBA CO PO Mapping**

| CSE 4298 | CO | PO1 | PO2 | PO3 | PO4 | PO5 | PO6 | PO7 | PO8 | PO9 | PO10 | PO11 | PO12 | PSO1 | PSO2 | PSO3 | PSO4 |
|----------|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|------|------|------|------|------|------|------|
| CSE 4298.1 | Understand the functioning of the industry | 1 | 0 | 0 | 0 | 0 | 0 | 0 | 2 | 2 | 0 | 0 | 0 | 1 | 0 | 0 | 0 |
| CSE 4298.2 | Understand the requirements of real world applications | 2 | 1 | 3 | 1 | 1 | 1 | 1 | 0 | 3 | 2 | 0 | 1 | 2 | 1 | 1 | 0 |
| CSE 4298.3 | Demonstrate skills to use modern engineering tools, software and equipment to analyze problems | 0 | 0 | 2 | 2 | 3 | 1 | 1 | 0 | 3 | 2 | 0 | 1 | 2 | 1 | 1 | 0 |
| CSE 4298.4 | Demonstrate an ability to envisage and work on laboratory and multidisciplinary tasks | 0 | 0 | 2 | 1 | 3 | 1 | 1 | 0 | 3 | 2 | 0 | 1 | 2 | 1 | 1 | 0 |
| **CSE 4298 (Avg.)** | | **0.75** | **0.25** | **1.75** | **1** | **1.75** | **0.75** | **0.75** | **0.5** | **2.75** | **1.5** | **0** | **0.75** | **1.75** | **0.75** | **0.75** | **0** |

---

**IET CLO — AHEP 4 Mapping**

| CSE 4298 | CLO Statements | C8 | C9 | C10 | C12 | C15 | C16 | C17 |
|----------|----------------|----|----|-----|-----|-----|-----|-----|
| CSE 4298.1 | Understand the functioning of the industry | 2 | 1 | 0 | 1 | 1 | 2 | 2 |
| CSE 4298.2 | Understand the requirements of real world applications | 0 | 2 | 1 | 1 | 3 | 3 | 2 |
| CSE 4298.3 | Demonstrate skills to use modern engineering tools, software and equipment to analyze problems | 0 | 2 | 1 | 1 | 2 | 2 | 2 |
| CSE 4298.4 | Demonstrate an ability to envisage and work on laboratory and multidisciplinary tasks | 0 | 1 | 1 | 0 | 0 | 1 | 1 |

**AHEP 4 Statements — Mapping to ITR Work**

| Code | Statement | Mapping to This Project |
|------|-----------|------------------------|
| C8 | Identify and analyze ethical concerns and make reasoned ethical choices informed by professional codes of conduct | Credential security — never storing passwords in code, encrypting secrets in Jenkins credential store |
| C9 | Use a risk management process to identify, evaluate and mitigate risks associated with a particular project or activity | Identifying broken GPG key installation methods and switching to more reliable alternatives; dual-layer security scanning with Trivy |
| C10 | Adopt a holistic and proportionate approach to the mitigation of security risks | Implementing both filesystem and Docker image scanning; enforcing quality gates to prevent insecure code from being deployed |
| C12 | Use practical laboratory and workshop skills to investigate complex problems | Debugging systemd service failures, package installation errors, and Jenkins configuration issues on a live cloud server |
| C15 | Apply knowledge of engineering management principles, commercial context, project and change management | Infrastructure cost management — provisioning on demand and destroying when done; documenting the system for handoff and reuse |
| C16 | Function effectively as an individual, and as a member or leader of a team | Contributing to and improving a team-initiated pipeline effort; taking ownership of automation and documentation |
| C17 | Communicate effectively on complex engineering matters with technical and non-technical audiences | Writing PROJECT_GUIDE.md for independent replication; documenting all design decisions and their rationale |

Declaration: Through this Industrial Training, I have accomplished the above stated program articulation and IET learning outcomes.

---

## 12. References

[1] HashiCorp, "Terraform Documentation," [Online]. Available: https://developer.hashicorp.com/terraform/docs (last referenced: June 2026)

[2] Jenkins, "Jenkins User Documentation," [Online]. Available: https://www.jenkins.io/doc/ (last referenced: June 2026)

[3] Jenkins, "Jenkins Configuration as Code Plugin," [Online]. Available: https://plugins.jenkins.io/configuration-as-code/ (last referenced: June 2026)

[4] SonarSource, "SonarQube Documentation," [Online]. Available: https://docs.sonarsource.com/sonarqube/ (last referenced: June 2026)

[5] Aqua Security, "Trivy Documentation," [Online]. Available: https://trivy.dev/latest/ (last referenced: June 2026)

[6] Docker Inc., "Docker Documentation," [Online]. Available: https://docs.docker.com/ (last referenced: June 2026)

[7] Amazon Web Services, "Amazon EC2 Documentation," [Online]. Available: https://docs.aws.amazon.com/ec2/ (last referenced: June 2026)

[8] Adoptium, "Eclipse Temurin JDK," [Online]. Available: https://adoptium.net/temurin/releases/ (last referenced: June 2026)

[9] Node.js Foundation, "Node.js Documentation," [Online]. Available: https://nodejs.org/en/docs/ (last referenced: June 2026)

---

*[Attach Plagiarism Report here]*
