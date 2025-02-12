provider "aws" {
  region = var.region
}

# Get Default VPC
data "aws_vpc" "default" {
  default = true
}

# Get Default Subnets
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# Predefined security group rules
locals {
  security_group_rules = {
    ssh = {
      description = "SSH Access"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = var.allowed_ssh_ips
    }
    http = {
      description = "HTTP Access"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
    https = {
      description = "HTTPS Access"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
    custom1 = {
      description = "Custom Rule 1"
      from_port   = 8080
      to_port     = 8080
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
    custom2 = {
      description = "Custom Rule 2"
      from_port   = 3306
      to_port     = 3306
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
    custom3 = {
      description = "Custom Rule 3"
      from_port   = 5432
      to_port     = 5432
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
    custom4 = {
      description = "Custom Rule 4"
      from_port   = 27017
      to_port     = 27017
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
    custom5 = {
      description = "Custom Rule 5"
      from_port   = 9200
      to_port     = 9200
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
    custom6 = {
      description = "Custom Rule 6"
      from_port   = 6379
      to_port     = 6379
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
    custom7 = {
      description = "Custom Rule 7"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["192.168.1.0/24"]
    }
    custom8 = {
      description = "Custom Rule 8"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["192.168.1.0/24"]
    }
    custom9 = {
      description = "Custom Rule 9"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["192.168.1.0/24"]
    }
  }
}

# IAM Role and Instance Profile
resource "aws_iam_role" "ec2_role" {
  name = "${var.project_name}-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "ec2_policy" {
  name = "${var.project_name}-ec2-policy"
  role = aws_iam_role.ec2_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:Describe*",
          "s3:ListBucket",
          "s3:GetObject"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "${var.project_name}-instance-profile"
  role = aws_iam_role.ec2_role.name
}

# Create Security Groups if not provided
resource "aws_security_group" "ec2_sg" {
  count       = var.create_security_groups ? 1 : 0
  name        = "${var.project_name}-pcsg"
  description = "Security group for EC2 instance"
  vpc_id      = data.aws_vpc.default.id

  dynamic "ingress" {
    for_each = [for sg in var.allowed_security_groups : local.security_group_rules[sg]]
    content {
      description = ingress.value.description
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }

  # Allow All Outbound Traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-sg"
  }
}

# Create EC2 Instances
resource "aws_instance" "web" {
  count                       = var.instance_count
  ami                         = var.ami_id
  instance_type               = var.instance_type
  key_name                    = var.key_name
  subnet_id                   = tolist(data.aws_subnets.default.ids)[count.index % length(data.aws_subnets.default.ids)]
  vpc_security_group_ids      = var.create_security_groups ? [aws_security_group.ec2_sg[0].id] : var.allowed_security_groups
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.ec2_instance_profile.name

  root_block_device {
    volume_size           = var.volume_size
    volume_type           = var.volume_type
    encrypted             = var.encrypted_volume
    delete_on_termination = true
  }

  tags = {
    Name = "${var.project_name}-instance-${count.index}"
  }

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = var.ssh_user
      private_key = file(var.ssh_private_key_path)
      host        = self.public_ip
      agent       = false 
    }

    inline = [
      "sudo apt update -y",
      "sudo apt install -y ${join(" ", var.web_servers)}",
      "sudo systemctl start ${join(" && sudo systemctl start ", var.web_servers)}",
      "sudo systemctl enable ${join(" && sudo systemctl enable ", var.web_servers)}"
    ]
  }
}

# Optionally associate Elastic IPs
resource "aws_eip" "web_eip" {
  count      = var.associate_eip ? var.instance_count : 0
  instance   = element(aws_instance.web.*.id, count.index)
  vpc        = true
}

# CloudWatch Alarms for monitoring
resource "aws_cloudwatch_metric_alarm" "cpu_utilization" {
  count               = var.enable_monitoring ? var.instance_count : 0
  alarm_name          = "High-CPU-Utilization-${count.index}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "This metric monitors high CPU utilization"
  alarm_actions       = [] # Specify SNS topic ARN for notifications if needed

  dimensions = {
    InstanceId = element(aws_instance.web.*.id, count.index)
  }
}