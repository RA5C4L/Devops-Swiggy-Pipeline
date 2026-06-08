# Devops-Swiggy-Pipeline



\# Swiggy DevOps Pipeline



Built a full CI/CD pipeline that takes a Node.js food delivery app from source code to a live deployment on AWS — automatically. Every time code is pushed, it gets scanned, tested, containerized, and deployed without touching a server manually.



\---



\## What this does



Code goes in, a running app comes out. In between, Jenkins orchestrates everything:

\- SonarQube checks the code for bugs and bad practices

\- Trivy scans for security vulnerabilities twice — once in the source files, once in the final Docker image

\- Docker packages the app and pushes it to DockerHub

\- The container gets deployed and the app runs on port 3000



\---



\## Stack



\- \*\*Terraform\*\* — spins up the entire AWS infrastructure from code. One command to create everything, one command to tear it all down.

\- \*\*Jenkins\*\* — runs the pipeline automatically. Defined in a Jenkinsfile so the whole process is version controlled.

\- \*\*SonarQube\*\* — static analysis with a quality gate. If the code doesn't pass, the pipeline stops right there.

\- \*\*Trivy\*\* — scans both the filesystem and the Docker image for known CVEs.

\- \*\*Docker + DockerHub\*\* — containerizes the app and stores the image at `navneet117/swiggy:latest`

\- \*\*AWS EC2\*\* — Ubuntu 22.04 server running everything (us-east-1)



\---



\## Infrastructure



Defined in `terraform/main.tf`. Creates:

\- EC2 instance — c7i-flex.large, 30GB disk, Ubuntu 22.04

\- Security group — opens ports 22, 80, 443, 8080, 9000, 3000

\- Startup script — installs Java, Jenkins, Docker, SonarQube, and Trivy automatically on first boot



\---



\## Pipeline stages



Clean Workspace → Checkout Code → SonarQube Analysis → Quality Gate

→ Install Dependencies → Trivy FS Scan → Docker Build \& Push

→ Trivy Image Scan → Deploy Container



Full Jenkinsfile in `jenkins/Jenkinsfile`.



\---



\## Problems I ran into



This wasn't a smooth run. A few things broke along the way:



\*\*Jenkins wouldn't install via apt\*\*

The startup script used an outdated GPG key for the Jenkins repository. Linux refused to install from an unverified source. Fixed by downloading the Jenkins `.war` file directly and running it as a systemd service instead.



\*\*Jenkins failed to start after install\*\*

The latest Jenkins release dropped support for Java 17 — it now requires Java 21 minimum. The script installed Java 17. Had to install Temurin 21 and point the service to the right JDK path.



\*\*AMI not found\*\*

The original Terraform config had an AMI ID hardcoded for ap-south-1. When I switched to us-east-1, that AMI didn't exist. Had to query AWS for the correct Ubuntu 22.04 AMI in us-east-1.



\*\*Key pair region mismatch\*\*

Created the EC2 key pair in the wrong region. Terraform couldn't find it. Deleted and recreated in us-east-1.



\*\*Docker credentials not matching\*\*

Jenkins couldn't find the DockerHub credentials because the ID in the Jenkinsfile (`docker-creds`) didn't match what I'd named it in Jenkins (`docker-credentials`). Fixed by updating the credential ID.



\---



\## Running it yourself



You'll need AWS credentials configured and Terraform installed.



```bash

cd terraform

terraform init

terraform apply -auto-approve

```



After about 5 minutes the EC2 will be ready. Jenkins runs on port 8080, SonarQube on 9000.



When you're done:

```bash

terraform destroy -auto-approve

```



Don't forget this step — the instance type isn't free tier.



\---



\## What's next



The setup works but there are things I want to improve:

\- Fix the GPG key issue in `resource.sh` so the install is fully automated with no manual intervention

\- Add `variables.tf` so region, instance type, and key name are configurable without touching the main files

\- Add a GitHub webhook so the pipeline triggers on every push automatically

\- Add Slack or email notifications on pipeline failure



\---



Navneet Vivek — B.Tech CCE, Manipal Institute of Technology 2027

