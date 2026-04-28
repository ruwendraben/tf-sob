output "instance_id" {
  description = "EC2 instance ID"
  value       = module.ec2.instance_id
}

output "public_ip" {
  description = "Public static Elastic IP"
  value       = aws_eip.sob.public_ip
}

output "public_dns" {
  description = "Public DNS name"
  value       = module.ec2.public_dns
}

output "client_url" {
  description = "Client app URL"
  value       = "http://${aws_eip.sob.public_ip}"
}

output "author_url" {
  description = "Author admin panel URL"
  value       = "http://${aws_eip.sob.public_ip}:3001"
}

output "elastic_ip" {
  description = "Elastic IP address attached to the instance"
  value       = aws_eip.sob.public_ip
}
