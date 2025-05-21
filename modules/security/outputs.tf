



# output "security_group_id" {
#   description = "The security group ID"
#   value       = aws_security_group.patient_app.id
# }
output "security_group_id" {
  description = "ID of the security group"
  value       = aws_security_group.main.id
}