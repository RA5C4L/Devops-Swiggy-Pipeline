resource "aws_security_group" "Project-SG" {
  name        = "${var.app_name}-sg"
 description = "Security group for ${var.app_name} - opens ports for SSH, HTTP, HTTPS, Jenkins, SonarQube and app"

  ingress = [
    for port in [22, 80, 443, 8080, 9000, var.app_port] : {
      description      = "Allow port ${port}"
      from_port        = port
      to_port          = port
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    }
  ]

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.app_name}-sg"
  }
}

resource "aws_instance" "web" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.Project-SG.id]
  user_data              = file("./resource.sh")

  tags = {
    Name = var.instance_name
  }

  root_block_device {
    volume_size = var.volume_size
  }
}