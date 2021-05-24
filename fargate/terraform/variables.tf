variable "task_execution_role_arn" {}
variable "region" { default = "us-east-1"}
variable "environment" {}
variable "public_subnet1" {}
variable "public_subnet2" {}
variable "vpc_id" {}
variable "security_group_http_80" {}
variable "security_group_https" {}
variable "log_group" {}
variable "awslogs_stream_prefix" {}
variable "task_definition_name" {}
variable "ecr_image_version" {}
variable "ecr_repository_uri" {}




