data "aws_subnet" "selected" {
  for_each = toset(var.subnet_ids)
  id       = each.value
}

resource "aws_db_subnet_group" "this" {
  name       = var.db_identifier
  subnet_ids = var.subnet_ids
  tags       = local.db_tags
}

# quem precisa do banco (nós do eks, lambda de auth) anexa esse sg
resource "aws_security_group" "clients" {
  name        = "${var.db_identifier}-clients"
  description = "Clientes do RDS ${var.db_identifier}"
  vpc_id      = local.vpc_id
  tags        = local.db_tags
}

resource "aws_security_group" "rds" {
  name        = "${var.db_identifier}-sg"
  description = "RDS ${var.db_identifier}"
  vpc_id      = local.vpc_id
  tags        = local.db_tags
}

resource "aws_vpc_security_group_ingress_rule" "postgres_from_clients" {
  security_group_id            = aws_security_group.rds.id
  referenced_security_group_id = aws_security_group.clients.id
  ip_protocol                  = "tcp"
  from_port                    = 5432
  to_port                      = 5432
  description                  = "Postgres a partir do SG de clientes"
}

resource "aws_db_parameter_group" "this" {
  name   = var.db_identifier
  family = "postgres${split(".", var.engine_version)[0]}"

  parameter {
    name  = "rds.force_ssl"
    value = "1"
  }

  # loga query lenta (> 500ms)
  parameter {
    name  = "log_min_duration_statement"
    value = "500"
  }

  tags = local.db_tags
}

# senha gerada aqui e sem rotação, a lambda e a app recebem por env no deploy
resource "random_password" "master" {
  length           = 32
  special          = true
  override_special = "!#%^*-_=+"
}

resource "aws_cloudwatch_log_group" "postgresql" {
  name              = "/aws/rds/instance/${var.db_identifier}/postgresql"
  retention_in_days = var.log_retention_days
}

resource "aws_db_instance" "this" {
  identifier     = var.db_identifier
  engine         = "postgres"
  engine_version = var.engine_version
  instance_class = var.instance_class

  db_name  = var.db_name
  username = var.db_username
  password = random_password.master.result
  port     = 5432

  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage
  storage_type          = "gp3"
  storage_encrypted     = true

  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  parameter_group_name   = aws_db_parameter_group.this.name
  publicly_accessible    = false
  multi_az               = var.multi_az

  backup_retention_period = var.backup_retention_period
  backup_window           = "06:00-07:00"
  maintenance_window      = "sun:07:30-sun:08:30"

  auto_minor_version_upgrade      = true
  apply_immediately               = true
  enabled_cloudwatch_logs_exports = ["postgresql"]

  # ambiente de estudo, sobe e desce pelo pipeline
  deletion_protection      = false
  skip_final_snapshot      = true
  delete_automated_backups = true

  tags = local.db_tags

  depends_on = [aws_cloudwatch_log_group.postgresql]
}

resource "aws_secretsmanager_secret" "credentials" {
  name                    = "${var.db_identifier}/credentials"
  description             = "Credenciais do RDS ${var.db_identifier}"
  recovery_window_in_days = 0
  tags                    = local.db_tags
}

resource "aws_secretsmanager_secret_version" "credentials" {
  secret_id = aws_secretsmanager_secret.credentials.id
  secret_string = jsonencode({
    engine   = "postgres"
    host     = aws_db_instance.this.address
    port     = aws_db_instance.this.port
    dbname   = var.db_name
    username = var.db_username
    password = random_password.master.result
  })
}
