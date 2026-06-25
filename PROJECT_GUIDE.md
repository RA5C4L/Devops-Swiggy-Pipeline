# Devops-Swiggy-Pipeline — Project Guide

## What This Project Is

A complete end-to-end DevOps CI/CD pipeline built on AWS. It automatically provisions cloud infrastructure using Terraform and runs a full build, test, security scan, and deployment lifecycle through Jenkins — triggered on every code push.

The application being deployed is a Swiggy food-delivery clone (Node.js/React). The app itself is not the project — the pipeline infrastructure is.

---

## What It Does

Every time code is pushed to GitHub, the pipeline:

1. Pulls the latest source code
2. Runs a static code quality analysis (SonarQube)
3. Enforces a quality gate — aborts the build if code quality is below threshold
4. Installs dependencies
5. Scans source files for known CVEs (Trivy)
6. Builds a Docker image and pushes it to DockerHub
7. Scans the Docker image for vulnerabilities (Trivy)
8. Deploys the container to the server
9. Sends an email notification — success or failure

---

## Tech Stack

| Tool | Purpose |
|------|---------|
| Terraform | Provisions EC2 instance, security group, storage on AWS |
| AWS EC2 | The server everything runs on |
| Jenkins | Orchestrates the CI/CD pipeline |
| SonarQube | Static code analysis and quality gates |
| Trivy | CVE scanning for source code and Docker images |
| Docker | Containerizes and runs the application |
| DockerHub | Stores the built Docker image |
| Node.js | Runtime for the Swiggy app |

---

## What Gets Automated

Everything except entering your credentials. When `terraform apply` completes, the server has already:

- Installed Java 21, Java 17, NodeJS 20, Docker, Trivy
- Downloaded Jenkins and installed all required plugins
- Configured all tools (JDK, NodeJS, SonarQube Scanner, Docker)
- Set up the SonarQube server connection in Jenkins
- Created the Swiggy pipeline job
- Set all environment variables
- Created the SonarQube webhook pointing back to Jenkins

You only need to add two credentials and run the pipeline.

---

## Prerequisites

Before you start, make sure you have:

- AWS account with CLI configured (`aws sts get-caller-identity` should return your account ID)
- Terraform installed (`terraform -version`)
- Your AWS key pair `.pem` file downloaded to your machine
- DockerHub account
- Git Bash or any terminal with SSH support

---

## Step 1 — Clone the Repo

```bash
git clone https://github.com/RA5C4L/Devops-Swiggy-Pipeline.git
cd Devops-Swiggy-Pipeline
```

---

## Step 2 — Provision Infrastructure

```bash
cd terraform
terraform init
terraform apply -auto-approve
```

When it completes, you will see:

```
jenkins_url        = "http://<IP>:8080"
sonarqube_url      = "http://<IP>:9000"
ssh_command        = "ssh -i navneet.pem ubuntu@<IP>"
app_url            = "http://<IP>:3000"
```

Save the IP address — you will need it throughout.

---

## Step 3 — Wait for Server Setup to Complete

SSH into the instance:

```bash
ssh -i /path/to/your-key.pem ubuntu@<IP>
```

Watch the setup log:

```bash
tail -f /var/log/cloud-init-output.log
```

Wait until you see:

```
========== Setup Complete ==========
```

Press Ctrl+C to stop and exit the SSH session. The full setup takes 6-10 minutes.

---

## Step 4 — Open Jenkins

Open `http://<IP>:8080` in your browser.

Jenkins is fully configured — no setup wizard, no plugin installation, no tool configuration needed.

Log in with:
- Username: `admin`
- Password: `admin`

You will see the **Swiggy** pipeline job already created and ready to run.

---

## Step 5 — Get a SonarQube Token

Open `http://<IP>:9000` in a new tab.

- Login: `admin` / `admin` — change the password when prompted
- Top right corner — click your profile — **My Account**
- Click the **Security** tab
- Under Generate Tokens: Name = `sonar-token`, Type = `Global Analysis Token`
- Click **Generate** and copy the token immediately (shown only once)

---

## Step 6 — Add Two Credentials to Jenkins

This is the only manual step. Go to:

**Manage Jenkins -> Credentials -> System -> Global credentials -> Add Credentials**

**First — SonarQube token:**
- Kind: `Secret text`
- Secret: paste the sonar token you just copied
- ID: `sonar-token`
- Click Create

**Second — DockerHub:**
- Kind: `Username with password`
- Username: your DockerHub username
- Password: your DockerHub password
- ID: `docker-creds`
- Click Create

---

## Step 7 — Run the Pipeline

Go back to the Jenkins dashboard. Click **Swiggy** -> **Build Now**.

Watch the Stage View. The first run takes 5-10 minutes.

All 9 stages should go green:

```
Clean Workspace -> Checkout -> SonarQube Analysis -> Quality Gate ->
Install Dependencies -> Trivy FS Scan -> Docker Build & Push ->
Trivy Image Scan -> Deploy to Container
```

The app will be live at `http://<IP>:3000`.

---

## Step 8 — Destroy When Done

Run this to terminate all AWS resources and stop billing:

```bash
cd terraform
terraform destroy -auto-approve
```

Do not skip this step. The EC2 instance type used (c7i-flex.large) is not free tier.

---

## How Credentials Work

No passwords are stored in any file in this repo.

- **DockerHub and SonarQube credentials** are stored in Jenkins' encrypted credential store and injected at runtime using IDs (`docker-creds`, `sonar-token`).
- **User-specific configuration** (DockerHub username, repo URL, email) is set in `jenkins/jenkins.yaml` and applied automatically on boot — not in the Jenkinsfile.
- The **Jenkinsfile contains zero hardcoded user values** — it only references variable names.

---

## How to Customise for a Different User

Edit `jenkins/jenkins.yaml` before running `terraform apply`. Change these four values:

```yaml
- key: "DOCKERHUB_USER"
  value: "your-dockerhub-username"
- key: "APP_NAME"
  value: "your-app-name"
- key: "APP_REPO_URL"
  value: "https://github.com/your-username/your-app-repo.git"
- key: "NOTIFICATION_EMAIL"
  value: "your-email@gmail.com"
```

Also update the pipeline job repo URL in the `jobs` section:

```yaml
url('https://github.com/your-username/Devops-Swiggy-Pipeline.git')
```

Then run `terraform apply` as normal. Jenkins boots with your values already configured.

---

## How to Customise for a Different App

To deploy a different application instead of the Swiggy clone, your app's GitHub repo must have a `Dockerfile` at the root. Then just change `APP_REPO_URL` and `APP_NAME` in `jenkins/jenkins.yaml`.

The Terraform infrastructure and Jenkins pipeline stages stay exactly the same.

---

## Known Notes

- Jenkins takes about 90 seconds to fully start after boot. If it does not respond immediately, wait and refresh.
- SonarQube takes 2-3 minutes to be ready inside its Docker container. This is handled automatically.
- Gmail requires an App Password for SMTP (not your regular Gmail password). Generate one at: Google Account -> Security -> 2-Step Verification -> App Passwords.
- The `.pem` key file must have restricted permissions. If SSH fails with a permission error on Windows, run: `icacls "navneet.pem" /inheritance:r /grant:r "%USERNAME%:R"`
- Never commit your `.pem` file or `terraform.tfstate` — both are gitignored in this repo.
