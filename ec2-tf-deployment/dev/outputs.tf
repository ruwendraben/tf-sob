output "instance_id" {
  description = "EC2 instance ID"
  value       = module.ec2.instance_id
}

output "public_ip" {
  description = "Public IP address"
  value       = module.ec2.public_ip
}

output "public_dns" {
  description = "Public DNS name"
  value       = module.ec2.public_dns
}

output "client_url" {
  description = "Client app URL"
  value       = "http://${module.ec2.public_dns}"
}

output "author_url" {
  description = "Author admin panel URL"
  value       = "http://${module.ec2.public_dns}:3001"
}
