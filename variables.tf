variable "region" {
  description = "AWS region"
  type        = string
}

variable "project_name" {
  description = "Project name for tagging resources"
  type        = string
}

variable "allowed_ssh_ips" {
  description = "List of allowed IPs for SSH access"
  type        = list(string)
}

variable "ami_id" {
  description = "Ubuntu AMI ID"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "key_name" {
  description = "Name of the SSH key pair"
  type        = string
}

variable "volume_size" {
  description = "Size of the root EBS volume"
  type        = number
}

variable "volume_type" {
  description = "Type of the root EBS volume"
  type        = string
}

variable "encrypted_volume" {
  description = "Encrypt the root volume"
  type        = bool
}

variable "instance_count" {
  description = "Number of EC2 instances to create"
  type        = number
}

variable "web_servers" {
  description = "List of web servers to install (e.g., apache2, nginx, httpd)"
  type        = list(string)
  default     = ["apache2", "nginx", "httpd"]
}

variable "allowed_security_groups" {
  description = "List of existing security group IDs to attach or predefined security group names (e.g., ssh, http, https)"
  type        = list(string)
  default     = []
}

variable "create_security_groups" {
  description = "Whether to create new security groups"
  type        = bool
  default     = true
}

variable "ssh_private_key_path" {
  description = "Path to the SSH private key file"
  type        = string
}

variable "ssh_user" {
  description = "SSH user for connecting to the EC2 instance"
  type        = string
  default     = "ubuntu"
}

variable "associate_eip" {
  description = "Whether to associate Elastic IPs with the instances"
  type        = bool
  default     = false
}

variable "enable_monitoring" {
  description = "Whether to enable CloudWatch monitoring and alarms"
  type        = bool
  default     = false
}