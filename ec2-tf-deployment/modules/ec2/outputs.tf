output "instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.sob.id
}

output "public_ip" {
  description = "Public IP address"
  value       = aws_instance.sob.public_ip
}

output "public_dns" {
  description = "Public DNS name"
  value       = aws_instance.sob.public_dns
}
