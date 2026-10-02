variable "db_identifier" {
  type = string
}

variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "environment" {
  type = string
}

variable "destroy" {
  type    = bool
  default = false
}

# rede
variable "subnet_ids" {
  type = list(string)
}

# banco
variable "engine_version" {
  type    = string
  default = "16"
}

variable "instance_class" {
  type    = string
  default = "db.t4g.micro"
}

variable "allocated_storage" {
  type    = number
  default = 20
}

variable "max_allocated_storage" {
  type    = number
  default = 50
}

variable "db_name" {
  type    = string
  default = "techchallenge"
}

variable "db_username" {
  type    = string
  default = "techchallenge"
}

variable "backup_retention_period" {
  type    = number
  default = 1
}

variable "multi_az" {
  type    = bool
  default = false
}

variable "log_retention_days" {
  type    = number
  default = 7
}
