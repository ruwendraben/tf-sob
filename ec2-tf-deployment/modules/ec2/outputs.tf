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

output "availability_zone" {
  description = "Availability zone of the EC2 instance"
  value       = aws_instance.sob.availability_zone
}
