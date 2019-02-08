# ecs.tf

data "template_file" "container" {
  template = "${file("terraform/modules/ecs-service/templates/ecs_container.json.tpl")}"

  vars {
    container_name = "${var.namespace}-${var.service_name}"
    docker_image   = "${var.docker_image}"
    fargate_cpu    = "${var.fargate_cpu}"
    fargate_memory = "${var.fargate_memory}"
    aws_region     = "${var.aws_region}"
    service_port   = "${var.service_port}"
    container_port = "${var.docker_port}"
    logs_group     = "${var.aws_log_group_name}"
    docker_env     = "${jsonencode(var.docker_env)}"
    docker_secrets = "${jsonencode(var.docker_secrets)}"
  }
}

resource "aws_ecs_task_definition" "task" {
  family                   = "${var.namespace}-${var.service_name}"
  execution_role_arn       = "${var.ecs_task_execution_role}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "${var.fargate_cpu}"
  memory                   = "${var.fargate_memory}"
  container_definitions    = "${data.template_file.container.rendered}"
}

resource "aws_service_discovery_service" "task-service" {
  name = "${var.service_name}"

  dns_config {
    namespace_id = "${var.aws_ecs_discover_namespace_id}"

    dns_records {
      ttl  = 10
      type = "A"
    }

    routing_policy = "MULTIVALUE"
  }

  health_check_custom_config {
    failure_threshold = 1
  }
}

resource "aws_ecs_service" "main" {
  name            = "${var.namespace}-${var.service_name}-service"
  cluster         = "${var.aws_ecs_cluster_id}"
  task_definition = "${aws_ecs_task_definition.task.arn}"
  desired_count   = "${var.app_count}"
  launch_type     = "FARGATE"

  network_configuration {
    security_groups  = ["${var.aws_security_group_id}"]
    subnets          = ["${var.aws_subnet_id}"]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = "${aws_alb_target_group.http.arn}"
    container_name   = "${var.namespace}-${var.service_name}"
    container_port   = "${var.docker_port}"
  }

  service_registries {
    registry_arn = "${aws_service_discovery_service.task-service.arn}"
  }

  depends_on = [
    "aws_alb_listener.listener",
  ]
}

resource "aws_alb_target_group" "http" {
  name        = "${var.namespace}-${var.service_name}-target-group"
  port        = "80"
  protocol    = "HTTP"
  vpc_id      = "${var.aws_vpc_id}"
  target_type = "ip"

  health_check {
    healthy_threshold   = "3"
    interval            = "30"
    protocol            = "HTTP"
    matcher             = "200"
    timeout             = "10"
    path                = "${var.health_check_path}"
    unhealthy_threshold = "10"
    port                = 80
  }
}

# Redirect all traffic from the ALB to the target group
resource "aws_alb_listener" "front_end" {
  load_balancer_arn = "${var.aws_alb_id}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }

}


# Redirect all traffic from the ALB to the target group
resource "aws_alb_listener" "listener" {
  load_balancer_arn = "${var.aws_alb_id}"
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = "${var.ssl_cert_arn}"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "HEALTHY"
      status_code  = "200"
    }
  }

}

resource "aws_alb_listener_rule" "task_listener_rule" {
  listener_arn      = "${aws_alb_listener.listener.arn}"
  priority          = "${var.alb_priority}"

  action {
    type = "authenticate-cognito"

    authenticate_cognito {
      user_pool_arn       = "${var.aws_cognito_user_pool_arn}"
      user_pool_client_id = "${var.aws_cognito_user_pool_client_id}"
      user_pool_domain    = "${var.aws_cognito_user_pool_domain}"
      session_cookie_name = "albsession-${var.service_name}"
      session_timeout     = 604800
      scope               = "openid"
    }
  }

  action {
    target_group_arn = "${aws_alb_target_group.http.id}"
    type             = "forward"
  }

  condition {
    field  = "host-header"
    values = ["${var.subdomain_name}"]
  }
}


# Traffic to the ECS cluster should only come from the ALB
resource "aws_security_group" "task" {
  name        = "${var.namespace}-${var.service_name}-task-security-group"
  description = "allow inbound access from the ALB only"
  vpc_id      = "${var.aws_vpc_id}"

  ingress {
    protocol        = "tcp"
    from_port       = "80"
    to_port         = "80"
    security_groups = ["${var.aws_security_group_id}"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_route53_record" "service" {
  zone_id = "${var.route53_zone_id}"
  name    = "${var.subdomain_name}"
  type    = "A"

  alias {
    evaluate_target_health = false
    name = "${var.aws_alb_dns_name}"
    zone_id = "${var.aws_alb_zone_id}"
  }
}
