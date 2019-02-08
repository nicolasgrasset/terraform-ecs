# variables.tf

variable "namespace" {
  description = "Namespace of the cluster"
  default = "beta"
}

variable "aws_region" {
  description = "The AWS region things are created in"
  default     = "us-east-1"
}

variable "ecs_autoscale_role" {
  description = "Role arn for the ecsAutocaleRole"
  # Probably created automatically the first time you ran the ECS tutorial on the web console
  default     = "arn:aws:iam::REPLACE_ME_WITH_AWS_ACCOUNT_ID:role/ecsAutoscaleRoles"
}

variable "ecs_task_execution_role" {
  description = "Role arn for the ecsTaskExecutionRole"
  # Probably created automatically the first time you ran the ECS tutorial on the web console
  default     = "arn:aws:iam::REPLACE_ME_WITH_AWS_ACCOUNT_ID:role/ecsTaskExecutionRole"
}

variable "az_count" {
  description = "Number of AZs to cover in a given region"
  default     = 2
}

variable "route53_zone_id" {
  description = "Route 53 zone ID"
  default     = ""  # Route 53 Zone for your domain
}

variable "aws_rds_security_group_id" {
  description = "Security group ID for RDS access"
  default = "sg-*******"  # Our Database isn't managed by Terraform, neither is its group
}

variable "aws_vpc_id" {
  description = "VPC ID"
  default = "vpc-0f******"  # We're sharing VPC with other application, so it's managed elsewhere
}

variable "aws_vpc_cidr_block" {
  description = "VPC CIDR Block"
  default = "172.30.0.0/16"  # Depends on your VPC
}

variable "aws_vpc_main_route_table_id" {
  description = "VPC Main Route Table ID"
  default = "rtb-0f*******"  # Depends on your VPC
}

variable "ssl_cert_arn" {
  description = "SSL Certificate ARN"
  default = "arn:aws:acm:us-east-1:REPLACE_ME_WITH_AWS_ACCOUNT_ID:certificate/REPLACE_ME_CERTIFICATE_ID"
}

variable "aws_cognito_user_pool_arn" {
  description = "The ARN of the Cognito user pool"
  default = "arn:aws:cognito-idp:us-east-1:REPLACE_ME_WITH_AWS_ACCOUNT_ID:userpool/REPLACE_ME_WITH_COGNITO_ID"
}

variable "aws_cognito_user_pool_domain" {
  description = "The domain prefix or fully-qualified domain name of the Cognito user pool"
  default = ""  # Domain name for cognito ie. auth.beta.peelinsights.com
}


terraform {
  backend "s3" {
    bucket = ""  # Name of the s3 bucket where you want Terraform to keep your states
    key = "terraform.tfstate"
    region = "us-east-1"
  }
}