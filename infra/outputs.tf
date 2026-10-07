output "db_identifier" {
  value = aws_db_instance.this.identifier
}

output "address" {
  value = aws_db_instance.this.address
}

output "port" {
  value = aws_db_instance.this.port
}

output "db_name" {
  value = var.db_name
}

output "credentials_secret_arn" {
  value = aws_secretsmanager_secret.credentials.arn
}

output "credentials_secret_name" {
  value = aws_secretsmanager_secret.credentials.name
}

output "clients_security_group_id" {
  value = aws_security_group.clients.id
}

output "clients_security_group_name" {
  value = aws_security_group.clients.name
}
