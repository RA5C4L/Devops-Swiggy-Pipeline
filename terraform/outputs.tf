# ========== Instance Info ==========
output "instance_public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.web.public_ip
}

output "instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.web.id
}

# ========== Service URLs ==========
output "jenkins_url" {
  description = "Jenkins dashboard URL"
  value       = "http://${aws_instance.web.public_ip}:8080"
}

output "sonarqube_url" {
  description = "SonarQube dashboard URL"
  value       = "http://${aws_instance.web.public_ip}:9000"
}

output "app_url" {
  description = "Application URL"
  value       = "http://${aws_instance.web.public_ip}:${var.app_port}"
}

# ========== SSH Command ==========
output "ssh_command" {
  description = "SSH command — replace /path/to/ with the full path to your .pem file"
  value       = "ssh -i /path/to/${var.key_name}.pem ubuntu@${aws_instance.web.public_ip}"
}