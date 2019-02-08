
module "network" {
  source = "modules/network"
  az_count = "${var.az_count}"
  aws_vpc_id = "${var.aws_vpc_id}"
  aws_vpc_main_route_table_id = "${var.aws_vpc_main_route_table_id}"
  aws_vpc_cidr_block = "${var.aws_vpc_cidr_block}"
}

module "logs" {
  source = "modules/logs"
  namespace = "${var.namespace}"
}

module "ecs-cluster" {
  source = "modules/ecs-cluster"
  namespace = "${var.namespace}"
  aws_subnet_id = "${module.network.aws_subnet_id}"
  aws_vpc_id = "${var.aws_vpc_id}"
  aws_rds_security_group_id = "${var.aws_rds_security_group_id}"
}

module "service-orchard" {

  source = "modules/ecs-service"

  namespace = "${var.namespace}"
  service_name = "orchard"
  docker_image = "*******.dkr.ecr.us-east-1.amazonaws.com/peel/orchard:develop"
  health_check_path = "/hc/"
  subdomain_name = "orchard.beta.test.com"

  docker_env = [
    {
      name = "ENVIRONMENT"
      value = "Production"
    }
  ]

  # Secret environment varibales stored in AWS SSM
  docker_secrets = [
    {
      name = "DJANGO_SECRET_KEY"
      valueFrom = "arn:aws:ssm:us-east-1:*******:parameter/beta_django_secret_key"
    }
  ]

  alb_priority = "10"

  # Port exposed by the docker image to redirect traffic to
  docker_port = 80

  # Port exposed by the service on the load balancer
  service_port = 80

  # Number of docker containers to run
  app_count = 2

  # Fargate instance CPU units to provision (1 vCPU = 1024 CPU units)
  fargate_cpu = "1024"

  # Fargate instance memory to provision (in MiB)
  fargate_memory = "2048"

  aws_region = "${var.aws_region}"
  ecs_autoscale_role = "${var.ecs_autoscale_role}"
  ecs_task_execution_role = "${var.ecs_task_execution_role}"
  az_count = "${var.az_count}"
  ssl_cert_arn = "${var.ssl_cert_arn}"

  aws_ecs_cluster_id = "${module.ecs-cluster.aws_ecs_cluster_id}"
  aws_ecs_discover_namespace_id = "${module.ecs-cluster.aws_ecs_discover_namespace_id}"
  aws_ecs_cluster_name = "${module.ecs-cluster.aws_ecs_cluster_name}"
  aws_security_group_id = "${module.ecs-cluster.aws_security_group_id}"
  aws_subnet_id = "${module.network.aws_subnet_id}"
  aws_vpc_id = "${var.aws_vpc_id}"
  aws_alb_id = "${module.ecs-cluster.aws_alb_id}"
  aws_alb_dns_name = "${module.ecs-cluster.alb_dns_name}"
  aws_alb_zone_id = "${module.ecs-cluster.alb_zone_id}"
  aws_log_group_name = "${module.logs.aws_cloudwatch_log_group_name}"
  route53_zone_id = "${var.route53_zone_id}"

  aws_cognito_user_pool_arn = "${var.aws_cognito_user_pool_arn}"
  aws_cognito_user_pool_client_id = "?????"  # On Cognito
  aws_cognito_user_pool_domain = "${var.aws_cognito_user_pool_domain}"
}

module "service-canvas" {

  source = "modules/ecs-service"

  namespace = "${var.namespace}"
  service_name = "canvas"
  docker_image = "*******.dkr.ecr.us-east-1.amazonaws.com/peel/canvas:develop"
  health_check_path = "/hc/"
  subdomain_name = "canvas.beta.test.com"

  docker_env = [
    {
      name = "ENVIRONMENT"
      value = "Production"
    }
  ]

  # Secret environment varibales stored in AWS SSM
  docker_secrets = [
    {
      name = "DJANGO_SECRET_KEY"
      valueFrom = "arn:aws:ssm:us-east-1:*******:parameter/peel_django_secret_key"
    },
    {
      name = "DJANGO_FIELD_SECRET_KEY"
      valueFrom = "arn:aws:ssm:us-east-1:*******:parameter/peel_django_field_secret_key"
    },
    {
      name = "AWS_ACCESS_KEY"
      valueFrom = "arn:aws:ssm:us-east-1:*******:parameter/peel_aws_access_key"
    },
    {
      name = "AWS_SECRET_KEY"
      valueFrom = "arn:aws:ssm:us-east-1:*******:parameter/peel_aws_secret_key"
    },
    {
      name = "AWS_S3_BUCKET_NAME"
      valueFrom = "arn:aws:ssm:us-east-1:*******:parameter/peel_media_s3_bucket"
    },
    {
      name = "GOOGLE_MAPS_API_KEY"
      valueFrom = "arn:aws:ssm:us-east-1:*******:parameter/google_maps_api_key"
    },
  ]

  alb_priority = "20"

  # Port exposed by the docker image to redirect traffic to
  docker_port = 80

  # Port exposed by the service on the load balancer
  service_port = 80

  # Number of docker containers to run
  app_count = 2

  # Fargate instance CPU units to provision (1 vCPU = 1024 CPU units)
  fargate_cpu = "512"

  # Fargate instance memory to provision (in MiB)
  fargate_memory = "1024"

  aws_region = "${var.aws_region}"
  ecs_autoscale_role = "${var.ecs_autoscale_role}"
  ecs_task_execution_role = "${var.ecs_task_execution_role}"
  az_count = "${var.az_count}"
  ssl_cert_arn = "${var.ssl_cert_arn}"

  aws_ecs_cluster_id = "${module.ecs-cluster.aws_ecs_cluster_id}"
  aws_ecs_discover_namespace_id = "${module.ecs-cluster.aws_ecs_discover_namespace_id}"
  aws_ecs_cluster_name = "${module.ecs-cluster.aws_ecs_cluster_name}"
  aws_security_group_id = "${module.ecs-cluster.aws_security_group_id}"
  aws_subnet_id = "${module.network.aws_subnet_id}"
  aws_vpc_id = "${var.aws_vpc_id}"
  aws_alb_id = "${module.ecs-cluster.aws_alb_id}"
  aws_alb_dns_name = "${module.ecs-cluster.alb_dns_name}"
  aws_alb_zone_id = "${module.ecs-cluster.alb_zone_id}"
  aws_log_group_name = "${module.logs.aws_cloudwatch_log_group_name}"
  route53_zone_id = "${var.route53_zone_id}"

  aws_cognito_user_pool_arn = "${var.aws_cognito_user_pool_arn}"
  aws_cognito_user_pool_client_id = "?????"  # On Cognito
  aws_cognito_user_pool_domain = "${var.aws_cognito_user_pool_domain}"
}