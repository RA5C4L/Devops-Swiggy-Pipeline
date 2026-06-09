# ========== AWS Configuration ==========
variable "aws_region" {
  description = "AWS region to deploy infrastructure"
  type        = string
  default     = "us-east-1"
}

# ========== EC2 Configuration ==========
variable "instance_type" {
  description = "EC2 instance type. Use t3.medium for light apps, c7i-flex.large for heavier builds"
  type        = string
  default     = "c7i-flex.large"
}

variable "key_name" {
  description = "Name of the AWS key pair for SSH access"
  type        = string
  default     = "navneet"
}

variable "volume_size" {
  description = "Root volume size in GB. 20 for static sites, 30 for Node/React, 50 for full stack with DB"
  type        = number
  default     = 30
}

variable "instance_name" {
  description = "Name tag for the EC2 instance"
  type        = string
  default     = "devops-server"
}

# ========== App Configuration ==========
variable "app_port" {
  description = "Port your application runs on. 3000 for Node/React, 8080 for Spring Boot, 80 for static sites"
  type        = number
  default     = 3000
}

variable "app_name" {
  description = "Name of your application — used for tagging"
  type        = string
  default     = "myapp"
}

# ========== AMI Configuration ==========
variable "ami_id" {
  description = "Ubuntu 22.04 AMI ID. This is region-specific — check AWS console if you change regions"
  type        = string
  default     = "ami-0c7217cdde317cfec" # Ubuntu 22.04 us-east-1
}