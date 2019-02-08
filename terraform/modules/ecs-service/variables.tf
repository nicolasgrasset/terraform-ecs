# variables.tf

variable "namespace" {
  description = "Namespace of the cluster"
}

variable "service_name" {
  description = "Name of the service to create"
}

variable "subdomain_name" {
  description = "Subdomain name for the service"
}

variable "docker_image" {
  description = "Docker image address"
}

variable "aws_region" {
  description = "The AWS region things are created in"
  default     = "us-east-1"
}

variable "az_count" {
  description = "Number of AZs to cover in a given region"
  default     = "2"
}

variable "alb_priority" {
  default = 10
}

variable "docker_env" {
  description = "Environment variables for the container"
  type = "list"
  default = []
}

variable "docker_secrets" {
  description = "Secret environment varibales stored in AWS SSM"
  type = "list"
  default = []
}

variable "docker_port" {
  description = "Port exposed by the docker image to redirect traffic to"
  default     = 80
}

variable "service_port" {
  description = "Port exposed by the service on the load balancer"
}

variable "app_count" {
  description = "Number of docker containers to run"
  default     = 3
}

variable "ecs_autoscale_role" {
  description = "Role arn for the ecsAutocaleRole"
}

variable "ecs_task_execution_role" {
  description = "Role arn for the ecsTaskExecutionRole"
}

variable "health_check_path" {
  default = "/hc/"
}

variable "fargate_cpu" {
  description = "Fargate instance CPU units to provision (1 vCPU = 1024 CPU units)"
  default     = "1024"
}

variable "fargate_memory" {
  description = "Fargate instance memory to provision (in MiB)"
  default     = "2048"
}

variable "aws_vpc_id" {
  description = "Security group id for network configuration"
}

variable "aws_security_group_id" {
  description = "Security group id for network configuration"
}

variable "aws_subnet_id" {
  description = "Subnet id for network configuration"
  type = "list"
}

variable "aws_alb_id" {
  description = "Load balancer ALB id for ALB target group"
}

variable "aws_alb_dns_name" {
  description = "Load balancer ALB DNS name for ALB target group"
}

variable "aws_alb_zone_id" {
  description = "Load balancer ALB Zone id for ALB target group"
}

variable "aws_ecs_cluster_id" {
  description = "ECS Cluster id"
}

variable "aws_ecs_cluster_name" {
  description = "ECS Cluster name"
}

variable "aws_log_group_name" {
  description = "Cloudwatch Log group name"
}

variable "route53_zone_id" {
  description = "Route 53 zone ID"
}

variable "ssl_cert_arn" {
  description = "SSL Certificate ARN"
}

variable "aws_cognito_user_pool_arn" {
  description = "The ARN of the Cognito user pool"
}

variable "aws_cognito_user_pool_client_id" {
  description = "The ID of the Cognito user pool client"
}

variable "aws_cognito_user_pool_domain" {
  description = "The domain prefix or fully-qualified domain name of the Cognito user pool"
}

variable "aws_ecs_discover_namespace_id" {
  description = "Namespace id for ECS Discovery service"
}
