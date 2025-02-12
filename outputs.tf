output "instance_public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.web[*].public_ip
}

output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.web[*].id
}

output "ec2_ssh_commands" {
  description = "SSH commands to connect to the EC2 instances"
  value       = [for ip in aws_instance.web[*].public_ip : "ssh ${var.ssh_user}@${ip}"]
}

output "elastic_ips" {
  description = "Elastic IPs associated with the instances"
  value       = aws_eip.web_eip[*].public_ip
}

output "instance_states" {
  description = "States of the EC2 instances"
  value       = aws_instance.web[*].instance_state
}

output "instance_types" {
  description = "Types of the EC2 instances"
  value       = aws_instance.web[*].instance_type
}