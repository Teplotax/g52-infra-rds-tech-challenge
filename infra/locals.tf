locals {
  project = "tech-challenge"
  squad   = "grupo-52"
  sigla   = "g52"

  common_tags = {
    environment = var.environment
    squad       = local.squad
    sigla       = local.sigla
    project     = local.project
  }

  db_tags = merge(local.common_tags, {
    resource = "rds"
    service  = var.db_identifier
  })

  vpc_id = data.aws_subnet.selected[var.subnet_ids[0]].vpc_id
}
