environment   = "hom"
db_identifier = "g52-rds-tech-challenge-hom"
aws_region    = "us-east-1"
destroy       = false

subnet_ids = ["subnet-0f8545b2a7f5196a2", "subnet-0f211081d9ccab538"]

engine_version          = "16"
instance_class          = "db.t3.micro"
allocated_storage       = 20
max_allocated_storage   = 50
db_name                 = "techchallenge"
db_username             = "techchallenge"
backup_retention_period = 1
multi_az                = false
log_retention_days      = 7
