variable "env" {}
variable "prefix" {}
variable "domains" {}
variable "front_acm_arn" {}
variable "frontend_origin_token" {}

data "aws_caller_identity" "current" {}