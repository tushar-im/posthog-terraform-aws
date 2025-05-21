# output "instance_id" {
#   description = "ID of the EC2 instance"
#   value       = aws_instance.django_app.id
# }

# output "public_ip" {
#   description = "Public IP of the EC2 instance"
#   value       = aws_instance.django_app.public_ip
# }


output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.app_server.id
}

output "public_ip" {
  description = "Public IP of the EC2 instance (Elastic IP)"
  value       = aws_eip.instance_eip.public_ip
}

output "elastic_ip_id" {
  description = "ID of the Elastic IP"
  value       = aws_eip.instance_eip.id
}